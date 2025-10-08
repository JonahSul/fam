/**
 * TODO Management Tools for Agent Mode
 * Allows AI agents to manage and complete TODO items on behalf of users
 */

import { AITool } from '../ai-tools.js';

export interface TodoItem {
  id: string;
  title: string;
  description: string;
  status: 'pending' | 'inProgress' | 'completed' | 'cancelled';
  priority: 'low' | 'medium' | 'high' | 'urgent';
  createdAt: Date;
  updatedAt: Date;
  dueDate?: Date;
  chatSessionId?: string;
  userId?: string;
  tags: string[];
  metadata: Record<string, any>;
  aiContext?: string;
}

export interface TodoUpdateRequest {
  todoId: string;
  updates: {
    status?: 'pending' | 'inProgress' | 'completed' | 'cancelled';
    title?: string;
    description?: string;
    priority?: 'low' | 'medium' | 'high' | 'urgent';
    dueDate?: string; // ISO date string
    tags?: string[];
    metadata?: Record<string, any>;
  };
}

export interface TodoCreateRequest {
  title: string;
  description: string;
  priority?: 'low' | 'medium' | 'high' | 'urgent';
  dueDate?: string; // ISO date string
  chatSessionId?: string;
  tags?: string[];
  aiContext?: string;
}

export class TodoToolsManager {
  private baseUrl: string;

  constructor(baseUrl: string = 'http://localhost:3000') {
    this.baseUrl = baseUrl;
  }

  /**
   * Get TODO management tools for AI agents
   */
  getTodoTools(): AITool[] {
    return [
      {
        name: 'get_user_todos',
        description: 'Get all TODO items for the current user, optionally filtered by status or priority',
        parameters: {
          type: 'object',
          properties: {
            status: {
              type: 'string',
              enum: ['pending', 'inProgress', 'completed', 'cancelled'],
              description: 'Filter TODOs by status'
            },
            priority: {
              type: 'string',
              enum: ['low', 'medium', 'high', 'urgent'],
              description: 'Filter TODOs by priority'
            },
            chatSessionId: {
              type: 'string',
              description: 'Filter TODOs by chat session ID'
            },
            limit: {
              type: 'number',
              description: 'Maximum number of TODOs to return',
              minimum: 1,
              maximum: 100,
              default: 50
            }
          },
          required: []
        }
      },
      {
        name: 'complete_todo',
        description: 'Mark a TODO item as completed',
        parameters: {
          type: 'object',
          properties: {
            todoId: {
              type: 'string',
              description: 'ID of the TODO item to complete'
            },
            completionNote: {
              type: 'string',
              description: 'Optional note about how the TODO was completed'
            }
          },
          required: ['todoId']
        }
      },
      {
        name: 'update_todo_status',
        description: 'Update the status of a TODO item',
        parameters: {
          type: 'object',
          properties: {
            todoId: {
              type: 'string',
              description: 'ID of the TODO item to update'
            },
            status: {
              type: 'string',
              enum: ['pending', 'inProgress', 'completed', 'cancelled'],
              description: 'New status for the TODO'
            },
            note: {
              type: 'string',
              description: 'Optional note explaining the status change'
            }
          },
          required: ['todoId', 'status']
        }
      },
      {
        name: 'create_todo',
        description: 'Create a new TODO item for the user',
        parameters: {
          type: 'object',
          properties: {
            title: {
              type: 'string',
              description: 'Title of the TODO item'
            },
            description: {
              type: 'string',
              description: 'Detailed description of the TODO'
            },
            priority: {
              type: 'string',
              enum: ['low', 'medium', 'high', 'urgent'],
              description: 'Priority level of the TODO',
              default: 'medium'
            },
            dueDate: {
              type: 'string',
              description: 'Due date in ISO format (YYYY-MM-DD)'
            },
            tags: {
              type: 'array',
              items: { type: 'string' },
              description: 'Tags to categorize the TODO'
            },
            aiContext: {
              type: 'string',
              description: 'Context about why this TODO was created by AI'
            }
          },
          required: ['title', 'description']
        }
      },
      {
        name: 'update_todo_details',
        description: 'Update details of a TODO item (title, description, priority, etc.)',
        parameters: {
          type: 'object',
          properties: {
            todoId: {
              type: 'string',
              description: 'ID of the TODO item to update'
            },
            title: {
              type: 'string',
              description: 'New title for the TODO'
            },
            description: {
              type: 'string',
              description: 'New description for the TODO'
            },
            priority: {
              type: 'string',
              enum: ['low', 'medium', 'high', 'urgent'],
              description: 'New priority for the TODO'
            },
            dueDate: {
              type: 'string',
              description: 'New due date in ISO format (YYYY-MM-DD)'
            },
            tags: {
              type: 'array',
              items: { type: 'string' },
              description: 'New tags for the TODO'
            }
          },
          required: ['todoId']
        }
      },
      {
        name: 'delete_todo',
        description: 'Delete a TODO item',
        parameters: {
          type: 'object',
          properties: {
            todoId: {
              type: 'string',
              description: 'ID of the TODO item to delete'
            },
            reason: {
              type: 'string',
              description: 'Reason for deleting the TODO'
            }
          },
          required: ['todoId']
        }
      },
      {
        name: 'get_todo_analytics',
        description: 'Get analytics about TODO completion and patterns',
        parameters: {
          type: 'object',
          properties: {
            timeRange: {
              type: 'string',
              enum: ['week', 'month', 'quarter', 'year'],
              description: 'Time range for analytics',
              default: 'month'
            },
            includeCompleted: {
              type: 'boolean',
              description: 'Include completed TODOs in analytics',
              default: true
            }
          },
          required: []
        }
      }
    ];
  }

  /**
   * Execute a TODO tool
   */
  async executeTodoTool(toolName: string, parameters: any): Promise<any> {
    try {
      switch (toolName) {
        case 'get_user_todos':
          return await this.getUserTodos(parameters);
        
        case 'complete_todo':
          return await this.completeTodo(parameters);
        
        case 'update_todo_status':
          return await this.updateTodoStatus(parameters);
        
        case 'create_todo':
          return await this.createTodo(parameters);
        
        case 'update_todo_details':
          return await this.updateTodoDetails(parameters);
        
        case 'delete_todo':
          return await this.deleteTodo(parameters);
        
        case 'get_todo_analytics':
          return await this.getTodoAnalytics(parameters);
        
        default:
          throw new Error(`Unknown TODO tool: ${toolName}`);
      }
    } catch (error) {
      console.error(`Error executing TODO tool ${toolName}:`, error);
      throw error;
    }
  }

  /**
   * Get user TODOs
   */
  private async getUserTodos(params: any): Promise<any> {
    const queryParams = new URLSearchParams();
    if (params.status) queryParams.append('status', params.status);
    if (params.priority) queryParams.append('priority', params.priority);
    if (params.chatSessionId) queryParams.append('chatSessionId', params.chatSessionId);
    if (params.limit) queryParams.append('limit', params.limit.toString());

    const response = await fetch(`${this.baseUrl}/api/todos?${queryParams}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to get TODOs: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Complete a TODO
   */
  private async completeTodo(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/todos/${params.todoId}/complete`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        completionNote: params.completionNote,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to complete TODO: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Update TODO status
   */
  private async updateTodoStatus(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/todos/${params.todoId}/status`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        status: params.status,
        note: params.note,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to update TODO status: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Create a TODO
   */
  private async createTodo(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/todos`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        title: params.title,
        description: params.description,
        priority: params.priority || 'medium',
        dueDate: params.dueDate,
        tags: params.tags || [],
        aiContext: params.aiContext,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to create TODO: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Update TODO details
   */
  private async updateTodoDetails(params: any): Promise<any> {
    const updateData: any = {};
    if (params.title) updateData.title = params.title;
    if (params.description) updateData.description = params.description;
    if (params.priority) updateData.priority = params.priority;
    if (params.dueDate) updateData.dueDate = params.dueDate;
    if (params.tags) updateData.tags = params.tags;

    const response = await fetch(`${this.baseUrl}/api/todos/${params.todoId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(updateData),
    });

    if (!response.ok) {
      throw new Error(`Failed to update TODO details: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Delete a TODO
   */
  private async deleteTodo(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/todos/${params.todoId}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        reason: params.reason,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to delete TODO: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Get TODO analytics
   */
  private async getTodoAnalytics(params: any): Promise<any> {
    const queryParams = new URLSearchParams();
    queryParams.append('timeRange', params.timeRange || 'month');
    queryParams.append('includeCompleted', (params.includeCompleted ?? true).toString());

    const response = await fetch(`${this.baseUrl}/api/todos/analytics?${queryParams}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to get TODO analytics: ${response.statusText}`);
    }

    return await response.json();
  }
}
