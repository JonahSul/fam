# FAM MCP Server

A Model Context Protocol (MCP) server that provides tools for accessing meeting information from the Basic Meeting List Toolbox (BMLT) API. This server enables AI assistants to search and retrieve recovery meeting information.

## Features

- 🔍 **BMLT Meeting Search**: Search for recovery meetings by location, day, format, and more
- 📊 **Structured Logging**: Production-ready logging with configurable log levels
- ⚙️ **Environment Configuration**: Flexible configuration via environment variables
- 🛡️ **Error Handling**: Comprehensive error handling and validation
- 🚀 **Production Ready**: Built with TypeScript, includes graceful shutdown handling

## Installation

### From Source

```bash
cd mcp-tool
npm install
npm run build
```

### As a Package

```bash
npm install -g .
```

## Configuration

The server can be configured using environment variables. Create a `.env` file based on `.env.example`:

```bash
cp .env.example .env
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BMLT_API_BASE` | Base URL for BMLT API | `https://bmlt.mtrna.org/prod` |
| `SERVER_VERSION` | Server version | `0.0.1` |
| `USER_AGENT` | User agent string for API requests | `fam/{version}` |
| `LOG_LEVEL` | Logging level (debug, info, warn, error) | `info` |

## Usage

### Running the Server

The MCP server communicates via standard input/output (stdio):

```bash
# Using npm
npm run build && node build/index.js

# Using the bin command (if installed globally)
fam
```

### Integrating with MCP Clients

Add to your MCP client configuration (e.g., Claude Desktop):

```json
{
  "mcpServers": {
    "fam": {
      "command": "node",
      "args": ["/path/to/mcp-tool/build/index.js"],
      "env": {
        "BMLT_API_BASE": "https://bmlt.mtrna.org/prod",
        "LOG_LEVEL": "info"
      }
    }
  }
}
```

Or if installed globally:

```json
{
  "mcpServers": {
    "fam": {
      "command": "fam"
    }
  }
}
```

## Available Tools

### bmlt_search

Search for meetings in the BMLT database.

**Parameters:**

- `location` (string, optional): Location to search for meetings (city, zip code, etc.)
- `weekday` (number, optional): Day of week (1=Sunday, 2=Monday, ..., 7=Saturday)
- `format` (string, optional): Meeting format to search for
- `limit` (number, optional): Maximum number of results to return (default: 50, max: 200)

**Example Usage:**

```typescript
// Search for meetings in Missoula
{
  "location": "Missoula, MT"
}

// Search for Monday meetings
{
  "weekday": 2,
  "location": "Montana"
}

// Search with limit
{
  "location": "59801",
  "limit": 10
}
```

**Response Format:**

Returns formatted meeting information including:
- Meeting name
- Time and duration
- Location (with address)
- Comments
- Meeting ID

## Development

### Project Structure

```
mcp-tool/
├── src/
│   ├── index.ts           # Main server entry point
│   ├── config.ts          # Configuration management
│   ├── logger.ts          # Logging utility
│   ├── tools.ts           # Tool loading and registration
│   └── tools/
│       ├── base-tool.ts   # Base tool interface
│       └── bmlt-client.ts # BMLT API client tool
├── build/                 # Compiled JavaScript output
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
```

### Building

```bash
npm run build
```

This compiles TypeScript to JavaScript in the `build/` directory and makes the main script executable.

### Adding New Tools

1. Create a new file in `src/tools/` (e.g., `my-tool.ts`)
2. Implement the `BaseTool` interface:

```typescript
import { z } from "zod";
import { BaseTool, ToolArgs, McpResponse } from "./base-tool.js";
import { ServerConfig } from "../config.js";
import { logger } from "../logger.js";

export class MyTool extends BaseTool {
  name = "my_tool";
  description = "Description of what this tool does";
  args: ToolArgs = {
    param1: z.string().describe("Description of param1"),
    param2: z.number().optional().describe("Optional parameter"),
  };

  private config: ServerConfig;

  constructor(config: ServerConfig) {
    super();
    this.config = config;
  }

  async callback(params: Record<string, any>): Promise<McpResponse> {
    try {
      logger.debug('MyTool called with params', params);
      
      // Your tool implementation here
      const result = await someOperation(params);
      
      return {
        content: [{
          type: "text",
          text: `Result: ${result}`
        }]
      };
    } catch (error) {
      logger.error('Error in MyTool', error, { params });
      return {
        content: [{
          type: "text",
          text: `Error: ${error instanceof Error ? error.message : 'Unknown error'}`
        }]
      };
    }
  }
}
```

3. The tool will be automatically loaded and registered by the server

### Testing

To test the server manually:

```bash
# Build the server
npm run build

# Run with debug logging
LOG_LEVEL=debug node build/index.js
```

The server will communicate via stdio, so you'll need an MCP client to interact with it properly.

## Logging

The server logs to stderr (stdout is reserved for MCP protocol communication). Log levels:

- **debug**: Detailed information for debugging
- **info**: General informational messages
- **warn**: Warning messages
- **error**: Error messages with stack traces

Set the log level using the `LOG_LEVEL` environment variable.

## Error Handling

The server includes comprehensive error handling:

- Configuration validation on startup
- Tool loading error handling
- API request error handling
- Graceful shutdown on SIGINT/SIGTERM
- Detailed error logging

## Production Deployment

### Best Practices

1. **Set appropriate log level**: Use `info` or `warn` in production
2. **Configure environment variables**: Don't rely on defaults for production
3. **Monitor logs**: Set up log aggregation for stderr output
4. **Resource limits**: Consider setting memory/CPU limits in your deployment
5. **Health checks**: Monitor server startup and shutdown logs

### Docker Deployment (Optional)

Create a `Dockerfile`:

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --production

COPY . .
RUN npm run build

CMD ["node", "build/index.js"]
```

Build and run:

```bash
docker build -t fam-mcp .
docker run -i fam-mcp
```

## Troubleshooting

### Server won't start

- Check that all dependencies are installed: `npm install`
- Verify build succeeded: `npm run build`
- Check configuration: Review environment variables and `.env` file

### Tool not found

- Ensure tool file is in `src/tools/` directory
- Verify tool class extends `BaseTool`
- Check build output for compilation errors
- Review server logs for tool loading messages

### API requests failing

- Verify `BMLT_API_BASE` is set correctly
- Check network connectivity
- Review API response in debug logs: `LOG_LEVEL=debug`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is part of Fellowship Access Montana. See LICENSE file for details.

## Support

For issues and questions:
- Open an issue in the repository
- Check existing documentation
- Review logs with `LOG_LEVEL=debug`

---

**Fellowship Access Montana** - Connecting people with recovery resources
