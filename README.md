# FAM - Fellowship Access Montana

'Fellowship Access Montana' is a project dedicated to delivering agentic AI-enabled services to members of the NA fellowship.

## Project Overview

This repository contains three distinct but related projects:

### 🔧 [mcp-tool](./mcp-tool/) - MCP Server
**Status: ✅ Production Ready**
- TypeScript-based Model Context Protocol (MCP) server
- BMLT (Basic Meeting List Toolbox) integration for NA meeting searches
- Auto-discovery tool loading system
- **Next Steps**: See [mcp-tool/TODO.md](./mcp-tool/TODO.md)

### 📱 [fam-app](./fam-app/) - React Native App
**Status: ⚠️ Needs Authentication Implementation**
- React Native app with Firebase integration
- Chat UI with Genkit AI agent (✅ Complete)
- Real-time messaging via Firestore (✅ Complete)
- **Blocker**: Missing authentication screens and route protection
- **Next Steps**: See [fam-app/TODO.md](./fam-app/TODO.md)

### 🎯 [mobile_app/montanagent](./mobile_app/montanagent/) - Flutter App
**Status: 🚧 MVP Ready, Needs Configuration**
- Flutter app with comprehensive architecture
- Authentication and chat features implemented
- **Blocker**: Hardcoded API keys need proper configuration
- **Next Steps**: See [mobile_app/montanagent/TODO.md](./mobile_app/montanagent/TODO.md)

## Quick Start

### MCP Tool
```bash
cd mcp-tool
npm install
npm run build
./build/index.js  # Run MCP server
```

### FAM App (React Native)
*Requires authentication implementation before use*

### MontaNAgent (Flutter)
*Requires Flutter SDK and API key configuration*

## Project Status Summary

- **MCP Tool**: ✅ Fully functional with BMLT integration
- **FAM App**: ⚠️ Core features complete, missing auth UI
- **MontaNAgent**: 🚧 Complete architecture, needs environment setup

Each project has a detailed TODO.md file with prioritized development roadmaps.