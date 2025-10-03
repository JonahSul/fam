import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { loadTools } from "./tools.js";
import { loadConfig, validateConfig } from "./config.js";
import { logger } from "./logger.js";

// Load and validate configuration
const config = loadConfig();
try {
  validateConfig(config);
  logger.setLevel(config.logLevel);
  logger.info('Configuration loaded successfully', { config });
} catch (error) {
  logger.error('Configuration validation failed', error);
  process.exit(1);
}

// Create server instance
const server = new McpServer({
  name: "fam",
  version: config.serverVersion,
});

// Load and register tools
async function setupTools() {
  const tools = await loadTools(config);

  // Register each tool with the MCP server
  for (const tool of tools) {
    // Convert our ToolArgs to Zod schema format expected by MCP
    const zodSchema: Record<string, z.ZodSchema> = {};
    for (const [key, schema] of Object.entries(tool.args)) {
      zodSchema[key] = schema;
    }

    server.tool(
      tool.name,
      tool.description,
      zodSchema,
      async (args: any) => {
        try {
          const result = await tool.callback(args || {});
          return result;
        } catch (error) {
          return {
            content: [{
              type: "text",
              text: `Error executing tool ${tool.name}: ${error instanceof Error ? error.message : 'Unknown error'}`
            }]
          };
        }
      }
    );
  }

  logger.info(`Registered ${tools.length} tools with MCP server`);
}

// Rip it
async function main() {
  try {
    await setupTools();
    
    const transport = new StdioServerTransport();
    await server.connect(transport);
    logger.info("MCP Server running on stdio");
    
    // Graceful shutdown handling
    process.on('SIGINT', () => {
      logger.info('Received SIGINT, shutting down gracefully');
      process.exit(0);
    });
    
    process.on('SIGTERM', () => {
      logger.info('Received SIGTERM, shutting down gracefully');
      process.exit(0);
    });
    
  } catch (error) {
    logger.error("Failed to start MCP server", error);
    process.exit(1);
  }
}

main().catch((error) => {
  logger.error("Fatal error in main()", error);
  process.exit(1);
});