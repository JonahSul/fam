import { readdir } from "fs/promises";
import { join, dirname } from "path";
import { fileURLToPath } from "url";
import { Tool } from "./tools/base-tool.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Dynamically loads all tool classes from the tools directory
 * Excludes base-tool.ts which contains interfaces/base classes
 */
export async function loadTools(): Promise<Tool[]> {
  const tools: Tool[] = [];
  const toolsDir = join(__dirname, "tools");
  
  try {
    const files = await readdir(toolsDir);
    const toolFiles = files.filter(file => 
      file.endsWith(".js") && 
      file !== "base-tool.js"
    );

    for (const file of toolFiles) {
      try {
        const modulePath = `./tools/${file}`;
        const module = await import(modulePath);
        
        // Look for exported classes that extend BaseTool or implement Tool
        for (const exportedItem of Object.values(module)) {
          if (typeof exportedItem === "function" && exportedItem.prototype) {
            try {
              const instance = new (exportedItem as any)();
              if (isValidTool(instance)) {
                tools.push(instance);
                console.error(`Loaded tool: ${instance.name}`);
              }
            } catch (error) {
              console.error(`Failed to instantiate tool from ${file}:`, error);
            }
          }
        }
      } catch (error) {
        console.error(`Failed to load tool file ${file}:`, error);
      }
    }
  } catch (error) {
    console.error("Failed to read tools directory:", error);
  }

  console.error(`Loaded ${tools.length} tools total`);
  return tools;
}

/**
 * Type guard to check if an object implements the Tool interface
 */
function isValidTool(obj: any): obj is Tool {
  return (
    obj &&
    typeof obj.name === "string" &&
    typeof obj.description === "string" &&
    typeof obj.args === "object" &&
    typeof obj.callback === "function"
  );
}