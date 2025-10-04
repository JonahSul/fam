
import { z } from "zod";

export interface ToolArgs {
  [key: string]: z.ZodSchema;
}

export interface McpContent {
  type: "text";
  text: string;
  [key: string]: unknown;
}

export interface McpResponse {
  content: McpContent[];
  [key: string]: unknown;
}

export interface Tool {
  name: string;
  description: string;
  args: ToolArgs;
  callback: (params: Record<string, any>) => Promise<McpResponse>;
}

export abstract class BaseTool implements Tool {
  abstract name: string;
  abstract description: string;
  abstract args: ToolArgs;
  abstract callback(params: Record<string, any>): Promise<McpResponse>;
}