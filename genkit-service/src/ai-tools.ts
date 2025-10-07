/**
 * AI Tools Configuration for MontaNAgent
 * Defines the tools/functions the AI can call
 */

import { BmltService } from './bmlt-service.js';
import { TodoToolsManager } from './tools/todo-tools.js';
import { CalendarToolsManager } from './tools/calendar-tools.js';
import { GmailToolsManager } from './tools/gmail-tools.js';
import { MeetToolsManager } from './tools/meet-tools.js';

export interface AITool {
  name: string;
  description: string;
  parameters: {
    type: string;
    properties: Record<string, any>;
    required: string[];
  };
}

export class AIToolsManager {
  private bmltService: BmltService;
  private todoToolsManager: TodoToolsManager;
  private calendarToolsManager: CalendarToolsManager;
  private gmailToolsManager: GmailToolsManager;
  private meetToolsManager: MeetToolsManager;

  constructor(
    bmltService: BmltService,
    baseUrl: string = 'http://localhost:3000',
    googleApiKey?: string
  ) {
    this.bmltService = bmltService;
    this.todoToolsManager = new TodoToolsManager(baseUrl);
    this.calendarToolsManager = new CalendarToolsManager(baseUrl, googleApiKey);
    this.gmailToolsManager = new GmailToolsManager(baseUrl, googleApiKey);
    this.meetToolsManager = new MeetToolsManager(baseUrl, googleApiKey);
  }

  /**
   * Get all available tools for the AI
   */
  getTools(): AITool[] {
    const bmltTools = this.getBmltTools();
    const todoTools = this.todoToolsManager.getTodoTools();
    const calendarTools = this.calendarToolsManager.getCalendarTools();
    const gmailTools = this.gmailToolsManager.getGmailTools();
    const meetTools = this.meetToolsManager.getMeetTools();

    return [
      ...bmltTools,
      ...todoTools,
      ...calendarTools,
      ...gmailTools,
      ...meetTools,
    ];
  }

  /**
   * Get BMLT (meeting search) tools
   */
  private getBmltTools(): AITool[] {
    return [
      {
        name: 'search_meetings',
        description: 'Search for NA meetings using various criteria like location, day, format, etc.',
        parameters: {
          type: 'object',
          properties: {
            location: {
              type: 'string',
              description: 'City, zip code, or address to search near'
            },
            weekday: {
              type: 'number',
              description: 'Day of the week (1=Sunday, 2=Monday, ..., 7=Saturday)',
              minimum: 1,
              maximum: 7
            },
            format: {
              type: 'string',
              description: 'Meeting format (Open, Closed, Speaker, Step Study, etc.)'
            },
            limit: {
              type: 'number',
              description: 'Maximum number of meetings to return',
              minimum: 1,
              maximum: 50,
              default: 20
            },
            radius: {
              type: 'number',
              description: 'Search radius in miles',
              minimum: 1,
              maximum: 100,
              default: 25
            }
          },
          required: []
        }
      },
      {
        name: 'get_todays_meetings',
        description: 'Get all NA meetings happening today',
        parameters: {
          type: 'object',
          properties: {
            location: {
              type: 'string',
              description: 'Optional city or location to filter by'
            }
          },
          required: []
        }
      },
      {
        name: 'get_meetings_for_day',
        description: 'Get all NA meetings for a specific day of the week',
        parameters: {
          type: 'object',
          properties: {
            weekday: {
              type: 'number',
              description: 'Day of the week (1=Sunday, 2=Monday, ..., 7=Saturday)',
              minimum: 1,
              maximum: 7
            },
            location: {
              type: 'string',
              description: 'Optional city or location to filter by'
            }
          },
          required: ['weekday']
        }
      },
      {
        name: 'get_meetings_near_location',
        description: 'Find NA meetings near a specific location within a radius',
        parameters: {
          type: 'object',
          properties: {
            location: {
              type: 'string',
              description: 'City, zip code, or address to search near'
            },
            radius: {
              type: 'number',
              description: 'Search radius in miles',
              minimum: 1,
              maximum: 100,
              default: 25
            }
          },
          required: ['location']
        }
      },
      {
        name: 'get_meetings_by_format',
        description: 'Find NA meetings by specific format (Open, Closed, Speaker, etc.)',
        parameters: {
          type: 'object',
          properties: {
            format: {
              type: 'string',
              description: 'Meeting format (Open, Closed, Speaker, Step Study, Big Book Study, Newcomer, etc.)'
            },
            location: {
              type: 'string',
              description: 'Optional city or location to filter by'
            }
          },
          required: ['format']
        }
      }
    ];
  }

  /**
   * Execute a tool call
   */
  async executeTool(toolName: string, parameters: any): Promise<any> {
    try {
      // BMLT tools
      if (this.isBmltTool(toolName)) {
        return await this.executeBmltTool(toolName, parameters);
      }
      
      // TODO tools
      if (this.isTodoTool(toolName)) {
        return await this.todoToolsManager.executeTodoTool(toolName, parameters);
      }
      
      // Calendar tools
      if (this.isCalendarTool(toolName)) {
        return await this.calendarToolsManager.executeCalendarTool(toolName, parameters);
      }
      
      // Gmail tools
      if (this.isGmailTool(toolName)) {
        return await this.gmailToolsManager.executeGmailTool(toolName, parameters);
      }
      
      // Meet tools
      if (this.isMeetTool(toolName)) {
        return await this.meetToolsManager.executeMeetTool(toolName, parameters);
      }
      
      throw new Error(`Unknown tool: ${toolName}`);
    } catch (error) {
      console.error(`Error executing tool ${toolName}:`, error);
      throw error;
    }
  }

  /**
   * Execute BMLT tool
   */
  private async executeBmltTool(toolName: string, parameters: any): Promise<any> {
    switch (toolName) {
      case 'search_meetings':
        return await this.bmltService.searchMeetings(parameters);
      
      case 'get_todays_meetings':
        return await this.bmltService.getTodaysMeetings(parameters.location);
      
      case 'get_meetings_for_day':
        return await this.bmltService.getMeetingsForDay(parameters.weekday, parameters.location);
      
      case 'get_meetings_near_location':
        return await this.bmltService.getMeetingsNearLocation(parameters.location, parameters.radius || 25);
      
      case 'get_meetings_by_format':
        return await this.bmltService.getMeetingsByFormat(parameters.format, parameters.location);
      
      default:
        throw new Error(`Unknown BMLT tool: ${toolName}`);
    }
  }

  /**
   * Check if tool is a BMLT tool
   */
  private isBmltTool(toolName: string): boolean {
    const bmltTools = ['search_meetings', 'get_todays_meetings', 'get_meetings_for_day', 'get_meetings_near_location', 'get_meetings_by_format'];
    return bmltTools.includes(toolName);
  }

  /**
   * Check if tool is a TODO tool
   */
  private isTodoTool(toolName: string): boolean {
    const todoTools = this.todoToolsManager.getTodoTools().map(tool => tool.name);
    return todoTools.includes(toolName);
  }

  /**
   * Check if tool is a Calendar tool
   */
  private isCalendarTool(toolName: string): boolean {
    const calendarTools = this.calendarToolsManager.getCalendarTools().map(tool => tool.name);
    return calendarTools.includes(toolName);
  }

  /**
   * Check if tool is a Gmail tool
   */
  private isGmailTool(toolName: string): boolean {
    const gmailTools = this.gmailToolsManager.getGmailTools().map(tool => tool.name);
    return gmailTools.includes(toolName);
  }

  /**
   * Check if tool is a Meet tool
   */
  private isMeetTool(toolName: string): boolean {
    const meetTools = this.meetToolsManager.getMeetTools().map(tool => tool.name);
    return meetTools.includes(toolName);
  }

  /**
   * Get tool definitions in OpenAI function calling format
   */
  getOpenAITools(): any[] {
    return this.getTools().map(tool => ({
      type: 'function',
      function: {
        name: tool.name,
        description: tool.description,
        parameters: tool.parameters
      }
    }));
  }
}
