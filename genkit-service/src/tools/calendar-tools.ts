/**
 * Google Calendar Integration Tools for Agent Mode
 * Allows AI agents to manage calendar events on behalf of users
 */

import { AITool } from '../ai-tools.js';

export interface CalendarEvent {
  id?: string;
  title: string;
  description?: string;
  startTime: string; // ISO datetime string
  endTime: string; // ISO datetime string
  location?: string;
  attendees?: string[];
  isAllDay?: boolean;
  recurrence?: {
    frequency: 'daily' | 'weekly' | 'monthly' | 'yearly';
    interval: number;
    endDate?: string; // ISO date string
  };
  reminders?: {
    minutes: number;
    method: 'email' | 'popup';
  }[];
  metadata?: Record<string, any>;
}

export interface CalendarSearchParams {
  startTime?: string; // ISO datetime string
  endTime?: string; // ISO datetime string
  query?: string;
  maxResults?: number;
}

export class CalendarToolsManager {
  private baseUrl: string;
  private googleApiKey?: string;

  constructor(baseUrl: string = 'http://localhost:3000', googleApiKey?: string) {
    this.baseUrl = baseUrl;
    this.googleApiKey = googleApiKey;
  }

  /**
   * Get Google Calendar tools for AI agents
   */
  getCalendarTools(): AITool[] {
    return [
      {
        name: 'create_calendar_event',
        description: 'Create a new calendar event',
        parameters: {
          type: 'object',
          properties: {
            title: {
              type: 'string',
              description: 'Title of the calendar event'
            },
            description: {
              type: 'string',
              description: 'Description of the event'
            },
            startTime: {
              type: 'string',
              description: 'Start time in ISO format (YYYY-MM-DDTHH:mm:ss)'
            },
            endTime: {
              type: 'string',
              description: 'End time in ISO format (YYYY-MM-DDTHH:mm:ss)'
            },
            location: {
              type: 'string',
              description: 'Location of the event'
            },
            attendees: {
              type: 'array',
              items: { type: 'string' },
              description: 'Email addresses of attendees'
            },
            isAllDay: {
              type: 'boolean',
              description: 'Whether this is an all-day event',
              default: false
            },
            reminders: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  minutes: { type: 'number' },
                  method: { type: 'string', enum: ['email', 'popup'] }
                }
              },
              description: 'Reminder settings for the event'
            }
          },
          required: ['title', 'startTime', 'endTime']
        }
      },
      {
        name: 'search_calendar_events',
        description: 'Search for calendar events within a time range',
        parameters: {
          type: 'object',
          properties: {
            startTime: {
              type: 'string',
              description: 'Start time for search in ISO format (YYYY-MM-DDTHH:mm:ss)'
            },
            endTime: {
              type: 'string',
              description: 'End time for search in ISO format (YYYY-MM-DDTHH:mm:ss)'
            },
            query: {
              type: 'string',
              description: 'Search query to filter events'
            },
            maxResults: {
              type: 'number',
              description: 'Maximum number of events to return',
              minimum: 1,
              maximum: 100,
              default: 20
            }
          },
          required: []
        }
      },
      {
        name: 'get_todays_events',
        description: 'Get all events for today',
        parameters: {
          type: 'object',
          properties: {
            includeAllDay: {
              type: 'boolean',
              description: 'Include all-day events',
              default: true
            }
          },
          required: []
        }
      },
      {
        name: 'get_events_for_date',
        description: 'Get all events for a specific date',
        parameters: {
          type: 'object',
          properties: {
            date: {
              type: 'string',
              description: 'Date in ISO format (YYYY-MM-DD)'
            },
            includeAllDay: {
              type: 'boolean',
              description: 'Include all-day events',
              default: true
            }
          },
          required: ['date']
        }
      },
      {
        name: 'update_calendar_event',
        description: 'Update an existing calendar event',
        parameters: {
          type: 'object',
          properties: {
            eventId: {
              type: 'string',
              description: 'ID of the event to update'
            },
            title: {
              type: 'string',
              description: 'New title for the event'
            },
            description: {
              type: 'string',
              description: 'New description for the event'
            },
            startTime: {
              type: 'string',
              description: 'New start time in ISO format'
            },
            endTime: {
              type: 'string',
              description: 'New end time in ISO format'
            },
            location: {
              type: 'string',
              description: 'New location for the event'
            },
            attendees: {
              type: 'array',
              items: { type: 'string' },
              description: 'New list of attendee email addresses'
            }
          },
          required: ['eventId']
        }
      },
      {
        name: 'delete_calendar_event',
        description: 'Delete a calendar event',
        parameters: {
          type: 'object',
          properties: {
            eventId: {
              type: 'string',
              description: 'ID of the event to delete'
            },
            reason: {
              type: 'string',
              description: 'Reason for deleting the event'
            }
          },
          required: ['eventId']
        }
      },
      {
        name: 'schedule_na_meeting',
        description: 'Schedule a Narcotics Anonymous meeting in the calendar',
        parameters: {
          type: 'object',
          properties: {
            meetingTitle: {
              type: 'string',
              description: 'Title of the NA meeting'
            },
            meetingLocation: {
              type: 'string',
              description: 'Location of the meeting'
            },
            startTime: {
              type: 'string',
              description: 'Start time in ISO format (YYYY-MM-DDTHH:mm:ss)'
            },
            duration: {
              type: 'number',
              description: 'Duration in minutes',
              default: 60
            },
            isRecurring: {
              type: 'boolean',
              description: 'Whether this is a recurring meeting',
              default: false
            },
            recurrenceFrequency: {
              type: 'string',
              enum: ['weekly', 'monthly'],
              description: 'Frequency if recurring',
              default: 'weekly'
            },
            notes: {
              type: 'string',
              description: 'Additional notes about the meeting'
            }
          },
          required: ['meetingTitle', 'meetingLocation', 'startTime']
        }
      },
      {
        name: 'find_free_time',
        description: 'Find free time slots in the calendar',
        parameters: {
          type: 'object',
          properties: {
            startDate: {
              type: 'string',
              description: 'Start date to search from in ISO format (YYYY-MM-DD)'
            },
            endDate: {
              type: 'string',
              description: 'End date to search until in ISO format (YYYY-MM-DD)'
            },
            duration: {
              type: 'number',
              description: 'Duration of free time needed in minutes',
              default: 60
            },
            preferredTimes: {
              type: 'array',
              items: { type: 'string' },
              description: 'Preferred time slots (e.g., ["09:00", "14:00"])'
            }
          },
          required: ['startDate', 'endDate']
        }
      }
    ];
  }

  /**
   * Execute a calendar tool
   */
  async executeCalendarTool(toolName: string, parameters: any): Promise<any> {
    try {
      switch (toolName) {
        case 'create_calendar_event':
          return await this.createCalendarEvent(parameters);
        
        case 'search_calendar_events':
          return await this.searchCalendarEvents(parameters);
        
        case 'get_todays_events':
          return await this.getTodaysEvents(parameters);
        
        case 'get_events_for_date':
          return await this.getEventsForDate(parameters);
        
        case 'update_calendar_event':
          return await this.updateCalendarEvent(parameters);
        
        case 'delete_calendar_event':
          return await this.deleteCalendarEvent(parameters);
        
        case 'schedule_na_meeting':
          return await this.scheduleNAMeeting(parameters);
        
        case 'find_free_time':
          return await this.findFreeTime(parameters);
        
        default:
          throw new Error(`Unknown calendar tool: ${toolName}`);
      }
    } catch (error) {
      console.error(`Error executing calendar tool ${toolName}:`, error);
      throw error;
    }
  }

  /**
   * Create a calendar event
   */
  private async createCalendarEvent(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/calendar/events`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        title: params.title,
        description: params.description,
        startTime: params.startTime,
        endTime: params.endTime,
        location: params.location,
        attendees: params.attendees,
        isAllDay: params.isAllDay || false,
        reminders: params.reminders || [{ minutes: 15, method: 'popup' }],
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to create calendar event: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Search calendar events
   */
  private async searchCalendarEvents(params: any): Promise<any> {
    const queryParams = new URLSearchParams();
    if (params.startTime) queryParams.append('startTime', params.startTime);
    if (params.endTime) queryParams.append('endTime', params.endTime);
    if (params.query) queryParams.append('query', params.query);
    if (params.maxResults) queryParams.append('maxResults', params.maxResults.toString());

    const response = await fetch(`${this.baseUrl}/api/calendar/events/search?${queryParams}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to search calendar events: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Get today's events
   */
  private async getTodaysEvents(params: any): Promise<any> {
    const today = new Date().toISOString().split('T')[0];
    const startTime = `${today}T00:00:00`;
    const endTime = `${today}T23:59:59`;

    return await this.searchCalendarEvents({
      startTime,
      endTime,
      includeAllDay: params.includeAllDay,
    });
  }

  /**
   * Get events for a specific date
   */
  private async getEventsForDate(params: any): Promise<any> {
    const startTime = `${params.date}T00:00:00`;
    const endTime = `${params.date}T23:59:59`;

    return await this.searchCalendarEvents({
      startTime,
      endTime,
      includeAllDay: params.includeAllDay,
    });
  }

  /**
   * Update a calendar event
   */
  private async updateCalendarEvent(params: any): Promise<any> {
    const updateData: any = {};
    if (params.title) updateData.title = params.title;
    if (params.description) updateData.description = params.description;
    if (params.startTime) updateData.startTime = params.startTime;
    if (params.endTime) updateData.endTime = params.endTime;
    if (params.location) updateData.location = params.location;
    if (params.attendees) updateData.attendees = params.attendees;

    const response = await fetch(`${this.baseUrl}/api/calendar/events/${params.eventId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify(updateData),
    });

    if (!response.ok) {
      throw new Error(`Failed to update calendar event: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Delete a calendar event
   */
  private async deleteCalendarEvent(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/calendar/events/${params.eventId}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        reason: params.reason,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to delete calendar event: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Schedule an NA meeting
   */
  private async scheduleNAMeeting(params: any): Promise<any> {
    const startTime = new Date(params.startTime);
    const endTime = new Date(startTime.getTime() + (params.duration || 60) * 60000);

    const eventData = {
      title: params.meetingTitle,
      description: `NA Meeting${params.notes ? `\n\n${params.notes}` : ''}`,
      startTime: startTime.toISOString(),
      endTime: endTime.toISOString(),
      location: params.meetingLocation,
      reminders: [
        { minutes: 30, method: 'popup' },
        { minutes: 15, method: 'popup' },
      ],
      metadata: {
        type: 'na_meeting',
        isRecurring: params.isRecurring || false,
        recurrenceFrequency: params.recurrenceFrequency || 'weekly',
      },
    };

    if (params.isRecurring) {
      eventData.recurrence = {
        frequency: params.recurrenceFrequency || 'weekly',
        interval: 1,
      };
    }

    return await this.createCalendarEvent(eventData);
  }

  /**
   * Find free time slots
   */
  private async findFreeTime(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/calendar/free-time`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        startDate: params.startDate,
        endDate: params.endDate,
        duration: params.duration || 60,
        preferredTimes: params.preferredTimes,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to find free time: ${response.statusText}`);
    }

    return await response.json();
  }
}
