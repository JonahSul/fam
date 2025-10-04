/**
 * Configuration management for MCP server
 * Loads configuration from environment variables with sensible defaults
 */

import { config as dotenvConfig } from 'dotenv';

// Load .env file if it exists (useful for development)
dotenvConfig();

export interface ServerConfig {
  bmltApiBase: string;
  serverVersion: string;
  userAgent: string;
  logLevel: 'debug' | 'info' | 'warn' | 'error';
}

/**
 * Load configuration from environment variables
 * Falls back to defaults if environment variables are not set
 */
export function loadConfig(): ServerConfig {
  return {
    bmltApiBase: process.env.BMLT_API_BASE || 'https://bmlt.mtrna.org/prod',
    serverVersion: process.env.SERVER_VERSION || '0.0.1',
    userAgent: process.env.USER_AGENT || `fam/${process.env.SERVER_VERSION || '0.0.1'}`,
    logLevel: (process.env.LOG_LEVEL as ServerConfig['logLevel']) || 'info',
  };
}

/**
 * Validate configuration
 * Throws an error if required configuration is missing or invalid
 */
export function validateConfig(config: ServerConfig): void {
  if (!config.bmltApiBase) {
    throw new Error('BMLT_API_BASE is required');
  }

  if (!config.bmltApiBase.startsWith('http')) {
    throw new Error('BMLT_API_BASE must be a valid URL');
  }

  if (!config.serverVersion) {
    throw new Error('SERVER_VERSION is required');
  }

  const validLogLevels = ['debug', 'info', 'warn', 'error'];
  if (!validLogLevels.includes(config.logLevel)) {
    throw new Error(`LOG_LEVEL must be one of: ${validLogLevels.join(', ')}`);
  }
}
