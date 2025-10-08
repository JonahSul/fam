/**
 * Google Meet Integration Tools for Agent Mode
 * Allows AI agents to create and manage Google Meet sessions on behalf of users
 */

import { AITool } from '../ai-tools.js';

export interface MeetSession {
  id?: string;
  title: string;
  description?: string;
  startTime: string; // ISO datetime string
  duration: number; // in minutes
  attendees: string[]; // email addresses
  isRecurring?: boolean;
  recurrencePattern?: {
    frequency: 'daily' | 'weekly' | 'monthly';
    interval: number;
    endDate?: string; // ISO date string
  };
  meetingUrl?: string;
  joinUrl?: string;
  meetingId?: string;
  passcode?: string;
  waitingRoom?: boolean;
  recordingEnabled?: boolean;
  chatEnabled?: boolean;
  screenSharingEnabled?: boolean;
}

export interface MeetInvite {
  meetingId: string;
  title: string;
  startTime: string;
  duration: number;
  joinUrl: string;
  passcode?: string;
  attendees: string[];
  calendarEventId?: string;
}

export class MeetToolsManager {
  private baseUrl: string;
  private googleApiKey?: string;

  constructor(baseUrl: string = 'http://localhost:3000', googleApiKey?: string) {
    this.baseUrl = baseUrl;
    this.googleApiKey = googleApiKey;
  }

  /**
   * Get Google Meet tools for AI agents
   */
  getMeetTools(): AITool[] {
    return [
      {
        name: 'create_meet_session',
        description: 'Create a new Google Meet session',
        parameters: {
          type: 'object',
          properties: {
            title: {
              type: 'string',
              description: 'Title of the meeting'
            },
            description: {
              type: 'string',
              description: 'Description of the meeting'
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
            attendees: {
              type: 'array',
              items: { type: 'string' },
              description: 'Email addresses of attendees'
            },
            isRecurring: {
              type: 'boolean',
              description: 'Whether this is a recurring meeting',
              default: false
            },
            recurrencePattern: {
              type: 'object',
              properties: {
                frequency: {
                  type: 'string',
                  enum: ['daily', 'weekly', 'monthly'],
                  description: 'Recurrence frequency'
                },
                interval: {
                  type: 'number',
                  description: 'Recurrence interval',
                  default: 1
                },
                endDate: {
                  type: 'string',
                  description: 'End date for recurrence in ISO format'
                }
              },
              description: 'Recurrence pattern for the meeting'
            },
            settings: {
              type: 'object',
              properties: {
                waitingRoom: {
                  type: 'boolean',
                  description: 'Enable waiting room',
                  default: false
                },
                recordingEnabled: {
                  type: 'boolean',
                  description: 'Enable recording',
                  default: false
                },
                chatEnabled: {
                  type: 'boolean',
                  description: 'Enable chat',
                  default: true
                },
                screenSharingEnabled: {
                  type: 'boolean',
                  description: 'Enable screen sharing',
                  default: true
                }
              },
              description: 'Meeting settings'
            }
          },
          required: ['title', 'startTime', 'attendees']
        }
      },
      {
        name: 'create_instant_meet',
        description: 'Create an instant Google Meet session that starts immediately',
        parameters: {
          type: 'object',
          properties: {
            title: {
              type: 'string',
              description: 'Title of the instant meeting'
            },
            duration: {
              type: 'number',
              description: 'Duration in minutes',
              default: 60
            },
            attendees: {
              type: 'array',
              items: { type: 'string' },
              description: 'Email addresses of attendees to invite'
            },
            settings: {
              type: 'object',
              properties: {
                waitingRoom: {
                  type: 'boolean',
                  description: 'Enable waiting room',
                  default: false
                },
                recordingEnabled: {
                  type: 'boolean',
                  description: 'Enable recording',
                  default: false
                },
                chatEnabled: {
                  type: 'boolean',
                  description: 'Enable chat',
                  default: true
                }
              },
              description: 'Meeting settings'
            }
          },
          required: ['title']
        }
      },
      {
        name: 'create_na_meeting_room',
        description: 'Create a Google Meet session specifically for NA meetings',
        parameters: {
          type: 'object',
          properties: {
            meetingName: {
              type: 'string',
              description: 'Name of the NA meeting'
            },
            meetingType: {
              type: 'string',
              enum: ['open', 'closed', 'speaker', 'step_study', 'big_book', 'newcomer'],
              description: 'Type of NA meeting'
            },
            startTime: {
              type: 'string',
              description: 'Start time in ISO format (YYYY-MM-DDTHH:mm:ss)'
            },
            duration: {
              type: 'number',
              description: 'Duration in minutes',
              default: 90
            },
            isRecurring: {
              type: 'boolean',
              description: 'Whether this is a recurring meeting',
              default: true
            },
            recurrenceFrequency: {
              type: 'string',
              enum: ['weekly', 'monthly'],
              description: 'Recurrence frequency for NA meetings',
              default: 'weekly'
            },
            facilitator: {
              type: 'string',
              description: 'Email of the meeting facilitator'
            },
            coFacilitator: {
              type: 'string',
              description: 'Email of the co-facilitator (optional)'
            },
            notes: {
              type: 'string',
              description: 'Additional notes about the meeting'
            }
          },
          required: ['meetingName', 'meetingType', 'startTime']
        }
      },
      {
        name: 'get_meet_session_info',
        description: 'Get information about a Google Meet session',
        parameters: {
          type: 'object',
          properties: {
            meetingId: {
              type: 'string',
              description: 'ID of the meeting to get info for'
            }
          },
          required: ['meetingId']
        }
      },
      {
        name: 'update_meet_session',
        description: 'Update an existing Google Meet session',
        parameters: {
          type: 'object',
          properties: {
            meetingId: {
              type: 'string',
              description: 'ID of the meeting to update'
            },
            title: {
              type: 'string',
              description: 'New title for the meeting'
            },
            description: {
              type: 'string',
              description: 'New description for the meeting'
            },
            startTime: {
              type: 'string',
              description: 'New start time in ISO format'
            },
            duration: {
              type: 'number',
              description: 'New duration in minutes'
            },
            attendees: {
              type: 'array',
              items: { type: 'string' },
              description: 'Updated list of attendee email addresses'
            }
          },
          required: ['meetingId']
        }
      },
      {
        name: 'cancel_meet_session',
        description: 'Cancel a Google Meet session',
        parameters: {
          type: 'object',
          properties: {
            meetingId: {
              type: 'string',
              description: 'ID of the meeting to cancel'
            },
            reason: {
              type: 'string',
              description: 'Reason for cancelling the meeting'
            },
            notifyAttendees: {
              type: 'boolean',
              description: 'Whether to notify attendees about the cancellation',
              default: true
            }
          },
          required: ['meetingId']
        }
      },
      {
        name: 'send_meet_invites',
        description: 'Send meeting invitations to attendees',
        parameters: {
          type: 'object',
          properties: {
            meetingId: {
              type: 'string',
              description: 'ID of the meeting'
            },
            attendees: {
              type: 'array',
              items: { type: 'string' },
              description: 'Email addresses to send invites to'
            },
            customMessage: {
              type: 'string',
              description: 'Custom message to include with the invitation'
            },
            reminderMinutes: {
              type: 'array',
              items: { type: 'number' },
              description: 'Minutes before meeting to send reminders',
              default: [60, 15]
            }
          },
          required: ['meetingId', 'attendees']
        }
      },
      {
        name: 'get_meet_attendance',
        description: 'Get attendance information for a completed meeting',
        parameters: {
          type: 'object',
          properties: {
            meetingId: {
              type: 'string',
              description: 'ID of the meeting'
            }
          },
          required: ['meetingId']
        }
      },
      {
        name: 'create_sponsor_meeting',
        description: 'Create a Google Meet session for sponsor-sponsee meetings',
        parameters: {
          type: 'object',
          properties: {
            sponsorEmail: {
              type: 'string',
              description: 'Email of the sponsor'
            },
            sponseeEmail: {
              type: 'string',
              description: 'Email of the sponsee'
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
            meetingPurpose: {
              type: 'string',
              enum: ['step_work', 'check_in', 'crisis_support', 'general_support'],
              description: 'Purpose of the sponsor meeting'
            },
            isRecurring: {
              type: 'boolean',
              description: 'Whether this is a recurring meeting',
              default: true
            },
            notes: {
              type: 'string',
              description: 'Notes about the meeting'
            }
          },
          required: ['sponsorEmail', 'sponseeEmail', 'startTime']
        }
      }
    ];
  }

  /**
   * Execute a Meet tool
   */
  async executeMeetTool(toolName: string, parameters: any): Promise<any> {
    try {
      switch (toolName) {
        case 'create_meet_session':
          return await this.createMeetSession(parameters);
        
        case 'create_instant_meet':
          return await this.createInstantMeet(parameters);
        
        case 'create_na_meeting_room':
          return await this.createNAMeetingRoom(parameters);
        
        case 'get_meet_session_info':
          return await this.getMeetSessionInfo(parameters);
        
        case 'update_meet_session':
          return await this.updateMeetSession(parameters);
        
        case 'cancel_meet_session':
          return await this.cancelMeetSession(parameters);
        
        case 'send_meet_invites':
          return await this.sendMeetInvites(parameters);
        
        case 'get_meet_attendance':
          return await this.getMeetAttendance(parameters);
        
        case 'create_sponsor_meeting':
          return await this.createSponsorMeeting(parameters);
        
        default:
          throw new Error(`Unknown Meet tool: ${toolName}`);
      }
    } catch (error) {
      console.error(`Error executing Meet tool ${toolName}:`, error);
      throw error;
    }
  }

  /**
   * Create a Meet session
   */
  private async createMeetSession(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/meet/sessions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        title: params.title,
        description: params.description,
        startTime: params.startTime,
        duration: params.duration || 60,
        attendees: params.attendees,
        isRecurring: params.isRecurring || false,
        recurrencePattern: params.recurrencePattern,
        settings: {
          waitingRoom: params.settings?.waitingRoom || false,
          recordingEnabled: params.settings?.recordingEnabled || false,
          chatEnabled: params.settings?.chatEnabled !== false,
          screenSharingEnabled: params.settings?.screenSharingEnabled !== false,
        },
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to create Meet session: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Create an instant Meet session
   */
  private async createInstantMeet(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/meet/instant`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        title: params.title,
        duration: params.duration || 60,
        attendees: params.attendees || [],
        settings: {
          waitingRoom: params.settings?.waitingRoom || false,
          recordingEnabled: params.settings?.recordingEnabled || false,
          chatEnabled: params.settings?.chatEnabled !== false,
        },
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to create instant Meet: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Create an NA meeting room
   */
  private async createNAMeetingRoom(params: any): Promise<any> {
    const meetingTypes = {
      open: 'Open Meeting',
      closed: 'Closed Meeting',
      speaker: 'Speaker Meeting',
      step_study: 'Step Study Meeting',
      big_book: 'Big Book Study',
      newcomer: 'Newcomer Meeting',
    };

    const title = `${meetingTypes[params.meetingType as keyof typeof meetingTypes]} - ${params.meetingName}`;
    const description = this.buildNAMeetingDescription(params);

    const response = await fetch(`${this.baseUrl}/api/meet/na-meetings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        title,
        description,
        meetingType: params.meetingType,
        startTime: params.startTime,
        duration: params.duration || 90,
        isRecurring: params.isRecurring !== false,
        recurrenceFrequency: params.recurrenceFrequency || 'weekly',
        facilitator: params.facilitator,
        coFacilitator: params.coFacilitator,
        notes: params.notes,
        settings: {
          waitingRoom: true, // NA meetings typically use waiting room
          recordingEnabled: false, // Privacy is important in NA meetings
          chatEnabled: true,
          screenSharingEnabled: true,
        },
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to create NA meeting room: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Get Meet session info
   */
  private async getMeetSessionInfo(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/meet/sessions/${params.meetingId}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to get Meet session info: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Update Meet session
   */
  private async updateMeetSession(params: any): Promise<any> {
    const updateData: any = {};
    if (params.title) updateData.title = params.title;
    if (params.description) updateData.description = params.description;
    if (params.startTime) updateData.startTime = params.startTime;
    if (params.duration) updateData.duration = params.duration;
    if (params.attendees) updateData.attendees = params.attendees;

    const response = await fetch(`${this.baseUrl}/api/meet/sessions/${params.meetingId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify(updateData),
    });

    if (!response.ok) {
      throw new Error(`Failed to update Meet session: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Cancel Meet session
   */
  private async cancelMeetSession(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/meet/sessions/${params.meetingId}/cancel`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        reason: params.reason,
        notifyAttendees: params.notifyAttendees !== false,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to cancel Meet session: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Send Meet invites
   */
  private async sendMeetInvites(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/meet/sessions/${params.meetingId}/invites`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        attendees: params.attendees,
        customMessage: params.customMessage,
        reminderMinutes: params.reminderMinutes || [60, 15],
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to send Meet invites: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Get Meet attendance
   */
  private async getMeetAttendance(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/meet/sessions/${params.meetingId}/attendance`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to get Meet attendance: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Create sponsor meeting
   */
  private async createSponsorMeeting(params: any): Promise<any> {
    const purposes = {
      step_work: 'Step Work Session',
      check_in: 'Check-in Meeting',
      crisis_support: 'Crisis Support Session',
      general_support: 'General Support Meeting',
    };

    const title = `Sponsor Meeting - ${purposes[params.meetingPurpose as keyof typeof purposes]}`;
    const description = this.buildSponsorMeetingDescription(params);

    const response = await fetch(`${this.baseUrl}/api/meet/sponsor-meetings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        title,
        description,
        sponsorEmail: params.sponsorEmail,
        sponseeEmail: params.sponseeEmail,
        startTime: params.startTime,
        duration: params.duration || 60,
        meetingPurpose: params.meetingPurpose,
        isRecurring: params.isRecurring !== false,
        notes: params.notes,
        settings: {
          waitingRoom: true, // Privacy for sponsor meetings
          recordingEnabled: false,
          chatEnabled: true,
          screenSharingEnabled: true,
        },
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to create sponsor meeting: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Build NA meeting description
   */
  private buildNAMeetingDescription(params: any): string {
    let description = `Narcotics Anonymous ${params.meetingType.replace('_', ' ').toUpperCase()} Meeting\n\n`;
    
    description += `Meeting Name: ${params.meetingName}\n`;
    description += `Type: ${params.meetingType.replace('_', ' ').toUpperCase()}\n`;
    
    if (params.facilitator) {
      description += `Facilitator: ${params.facilitator}\n`;
    }
    
    if (params.coFacilitator) {
      description += `Co-Facilitator: ${params.coFacilitator}\n`;
    }
    
    if (params.notes) {
      description += `\nNotes: ${params.notes}\n`;
    }
    
    description += `\nThis is a Narcotics Anonymous meeting. All are welcome to attend.`;
    
    if (params.meetingType === 'closed') {
      description += ` This is a closed meeting for addicts only.`;
    }
    
    return description;
  }

  /**
   * Build sponsor meeting description
   */
  private buildSponsorMeetingDescription(params: any): string {
    let description = `Sponsor-Sponsee Meeting\n\n`;
    
    description += `Purpose: ${params.meetingPurpose.replace('_', ' ').toUpperCase()}\n`;
    description += `Sponsor: ${params.sponsorEmail}\n`;
    description += `Sponsee: ${params.sponseeEmail}\n`;
    
    if (params.notes) {
      description += `\nNotes: ${params.notes}\n`;
    }
    
    description += `\nThis is a private meeting between sponsor and sponsee.`;
    
    return description;
  }
}
