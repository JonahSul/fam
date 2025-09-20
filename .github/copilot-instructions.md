# Copilot Instructions

## Project Overview
`fam` stands for 'Fellowship Access Montana', and is a project dedicated to delivering agentic AI-enabled services to members of the NA fellowship.

### MCP Tool
The `mcp-tool` directory contains a **Model Context Protocol (MCP) Tool** built with TypeScript and the `@modelcontextprotocol/sdk`. The project provides tools for interacting with external APIs through the MCP framework:
- BMLT (Basic Meeting List Toolbox) integration for Narcotics Anonymous meeting data
- (more planned...)

### MontaNAgent
The `mobile_app/montanagent` directory is the project root for a Flutter app which will deliver an agentic AI experience for users.

## Project Structure
```
/workspaces/namontana-fam/
├── mcp-tool/                   # MCP tool implementation
│   ├── src/
│   │   ├── index.ts            # MCP server entry point with auto tool loading
│   │   ├── tools.ts            # Tool discovery and loading system
│   │   └── tools/
│   │       ├── base-tool.ts    # Tool interface and base class
│   │       └── bmlt-client.ts  # BMLT API client tool
│   ├── build/                  # Compiled TypeScript output
│   ├── package.json            # Node.js dependencies and scripts
│   └── tsconfig.json           # TypeScript configuration
├── mobile_app/                 # Flutter mobile application base
│   └── montanagent/            # The MontaNAgent mobile app project root
├── .vscode/
│   ├── mcp.json                # MCP server configuration for VS Code
│   └── copilot-config.json     # Copilot MCP integration
└── .github/
    └── copilot-instructions.md # This file
```

## Architecture Patterns

### MCP Server Structure
- **Entry point**: `mcp-tool/src/index.ts` - Sets up the MCP server with stdio transport and auto-loads tools
- **Server configuration**: Uses `McpServer` from `@modelcontextprotocol/sdk/server/mcp.js`
- **Transport**: `StdioServerTransport` for stdio communication
- **Constants**: `BMLT_API_BASE` points to `https://bmlt.mtrna.org/prod` for external API integration

### Tool Implementation Pattern
- **Base interface**: `src/tools/base-tool.ts` defines the `Tool` interface and `BaseTool` abstract class
- **Tool classes**: Extend `BaseTool` (see `src/tools/bmlt-client.ts`)
- **Tool callback signature**: `async (params: Record<string, any>) => Promise<McpResponse>`
- **Auto-discovery**: `src/tools.ts` automatically scans and loads all tool classes from the `tools/` directory

### Code Conventions
- **ES Modules**: Uses `"type": "module"` in package.json with Node16 module resolution
- **TypeScript config**: Targets ES2022, outputs to `./build` directory
- **Import style**: Relative imports from local modules, explicit `.js` extensions for SDK imports
- **Tool arguments**: Use Zod schemas for parameter validation and description
- **Error handling**: Tool callbacks return structured error responses with `type: "text"` content

### MontaNAgent
- **Flutter App**: Uses/required Flutter

## Development Workflow

### Build Process
```bash
cd mcp-tool
npm run build  # Compiles TypeScript and makes index.js executable
```

### Adding New Tools
1. Create a new class in `mcp-tool/src/tools/` that extends `BaseTool`
2. Implement required properties: `name`, `description`, `args`, `callback`
3. Use Zod schemas for parameter validation in `args`
4. Return proper `McpResponse` objects from `callback`
5. Build - tools are automatically discovered and registered
6. **Important**: Restart the MCP server to load new compiled code

### Key Implementation Details

#### MCP Response Format
Tools must return objects matching this structure:
```typescript
{
  content: [
    {
      type: "text",
      text: "response content",
      [key: string]: unknown  // MCP allows additional properties
    }
  ],
  [key: string]: unknown  // MCP allows additional properties
}
```

#### Tool Schema Pattern
```typescript
args: ToolArgs = {
  paramName: z.string().optional().describe("Parameter description"),
  numParam: z.number().min(1).max(10).describe("Number with constraints")
}
```

#### BMLT Integration Specifics
- **API Format**: Uses JSONP endpoint that returns `/**/callback([...])` format
- **Search Parameters**: Supports location, weekday (1-7), format, and limit filtering
- **Weekday Mapping**: 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday
- **JSONP Parsing**: Custom parser extracts JSON from callback wrapper
- **Response Structure**: Direct array of meeting objects, not wrapped in data/meetings property

#### Tool Auto-Loading System
- `loadTools()` scans the `tools/` directory for `.js` files (excluding `base-tool.js`)
- Instantiates exported classes and validates they implement the `Tool` interface
- Registers tools with MCP server using `server.tool()` method
- Automatic Zod schema conversion for parameter validation

## Configuration Files
- **MCP Server**: `.vscode/mcp.json` configures the MCP server for VS Code integration
- **Copilot**: `.vscode/copilot-config.json` registers the server with GitHub Copilot
- **Path**: All paths should reference `./mcp-tool/build/index.js` relative to workspace root

## Critical Development Notes
- **Server Restart Required**: After building changes, the MCP server must be restarted to load new code
- **Debugging**: Use `console.error()` for debug output in tools (goes to stderr)
- **Testing**: Test tools via MCP calls, not direct function calls
- **JSONP Handling**: BMLT API returns JSONP format requiring special parsing