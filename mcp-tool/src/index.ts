import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { loadTools } from "./tools.js";

const SERVER_VERSION = "0.0.1"
const BMLT_API_BASE = "https://bmlt.mtrna.org/prod";
const USER_AGENT = "fam/" + SERVER_VERSION;

// Create server instance
const server = new McpServer({
  name: "fam",
  version: SERVER_VERSION,
});

// Load and register tools
async function setupTools() {
  const tools = await loadTools();

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

  console.error(`Registered ${tools.length} tools with MCP server`);
}

// Rip it
async function main() {
  await setupTools();
  
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("MontaNAgent running on stdio");
}

main().catch((error) => {
  console.error("Fatal error in main():", error);
  process.exit(1);
});