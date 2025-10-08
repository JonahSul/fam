/**
 * Gmail Integration Tools for Agent Mode
 * Allows AI agents to manage emails on behalf of users
 */

import { AITool } from '../ai-tools.js';

export interface EmailMessage {
  id?: string;
  to: string[];
  cc?: string[];
  bcc?: string[];
  subject: string;
  body: string;
  isHtml?: boolean;
  attachments?: {
    filename: string;
    content: string; // Base64 encoded
    contentType: string;
  }[];
  priority?: 'low' | 'normal' | 'high';
  replyTo?: string;
}

export interface EmailSearchParams {
  query?: string;
  from?: string;
  to?: string;
  subject?: string;
  hasAttachment?: boolean;
  isRead?: boolean;
  isImportant?: boolean;
  after?: string; // ISO date string
  before?: string; // ISO date string
  maxResults?: number;
}

export interface EmailTemplate {
  id: string;
  name: string;
  subject: string;
  body: string;
  variables: string[];
  category: 'recovery' | 'meeting' | 'sponsor' | 'general';
}

export class GmailToolsManager {
  private baseUrl: string;
  private googleApiKey?: string;

  constructor(baseUrl: string = 'http://localhost:3000', googleApiKey?: string) {
    this.baseUrl = baseUrl;
    this.googleApiKey = googleApiKey;
  }

  /**
   * Get Gmail tools for AI agents
   */
  getGmailTools(): AITool[] {
    return [
      {
        name: 'send_email',
        description: 'Send an email message',
        parameters: {
          type: 'object',
          properties: {
            to: {
              type: 'array',
              items: { type: 'string' },
              description: 'Recipient email addresses'
            },
            cc: {
              type: 'array',
              items: { type: 'string' },
              description: 'CC email addresses'
            },
            bcc: {
              type: 'array',
              items: { type: 'string' },
              description: 'BCC email addresses'
            },
            subject: {
              type: 'string',
              description: 'Email subject line'
            },
            body: {
              type: 'string',
              description: 'Email body content'
            },
            isHtml: {
              type: 'boolean',
              description: 'Whether the body is HTML format',
              default: false
            },
            priority: {
              type: 'string',
              enum: ['low', 'normal', 'high'],
              description: 'Email priority level',
              default: 'normal'
            },
            replyTo: {
              type: 'string',
              description: 'Reply-to email address'
            }
          },
          required: ['to', 'subject', 'body']
        }
      },
      {
        name: 'search_emails',
        description: 'Search for emails in the inbox',
        parameters: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'Search query (Gmail search syntax)'
            },
            from: {
              type: 'string',
              description: 'Filter by sender email'
            },
            to: {
              type: 'string',
              description: 'Filter by recipient email'
            },
            subject: {
              type: 'string',
              description: 'Filter by subject line'
            },
            hasAttachment: {
              type: 'boolean',
              description: 'Filter by emails with attachments'
            },
            isRead: {
              type: 'boolean',
              description: 'Filter by read/unread status'
            },
            isImportant: {
              type: 'boolean',
              description: 'Filter by important status'
            },
            after: {
              type: 'string',
              description: 'Filter emails after this date (ISO format)'
            },
            before: {
              type: 'string',
              description: 'Filter emails before this date (ISO format)'
            },
            maxResults: {
              type: 'number',
              description: 'Maximum number of emails to return',
              minimum: 1,
              maximum: 100,
              default: 20
            }
          },
          required: []
        }
      },
      {
        name: 'get_unread_emails',
        description: 'Get all unread emails',
        parameters: {
          type: 'object',
          properties: {
            maxResults: {
              type: 'number',
              description: 'Maximum number of emails to return',
              minimum: 1,
              maximum: 50,
              default: 20
            },
            priority: {
              type: 'string',
              enum: ['all', 'important', 'normal'],
              description: 'Filter by priority level',
              default: 'all'
            }
          },
          required: []
        }
      },
      {
        name: 'mark_email_as_read',
        description: 'Mark an email as read',
        parameters: {
          type: 'object',
          properties: {
            emailId: {
              type: 'string',
              description: 'ID of the email to mark as read'
            }
          },
          required: ['emailId']
        }
      },
      {
        name: 'mark_email_as_unread',
        description: 'Mark an email as unread',
        parameters: {
          type: 'object',
          properties: {
            emailId: {
              type: 'string',
              description: 'ID of the email to mark as unread'
            }
          },
          required: ['emailId']
        }
      },
      {
        name: 'delete_email',
        description: 'Delete an email',
        parameters: {
          type: 'object',
          properties: {
            emailId: {
              type: 'string',
              description: 'ID of the email to delete'
            },
            reason: {
              type: 'string',
              description: 'Reason for deleting the email'
            }
          },
          required: ['emailId']
        }
      },
      {
        name: 'reply_to_email',
        description: 'Reply to an email',
        parameters: {
          type: 'object',
          properties: {
            emailId: {
              type: 'string',
              description: 'ID of the email to reply to'
            },
            body: {
              type: 'string',
              description: 'Reply message body'
            },
            isHtml: {
              type: 'boolean',
              description: 'Whether the reply body is HTML format',
              default: false
            },
            includeOriginal: {
              type: 'boolean',
              description: 'Whether to include the original message',
              default: true
            }
          },
          required: ['emailId', 'body']
        }
      },
      {
        name: 'forward_email',
        description: 'Forward an email to another recipient',
        parameters: {
          type: 'object',
          properties: {
            emailId: {
              type: 'string',
              description: 'ID of the email to forward'
            },
            to: {
              type: 'array',
              items: { type: 'string' },
              description: 'Recipient email addresses'
            },
            message: {
              type: 'string',
              description: 'Additional message to include with the forward'
            }
          },
          required: ['emailId', 'to']
        }
      },
      {
        name: 'send_recovery_support_email',
        description: 'Send a recovery support email using predefined templates',
        parameters: {
          type: 'object',
          properties: {
            to: {
              type: 'array',
              items: { type: 'string' },
              description: 'Recipient email addresses'
            },
            template: {
              type: 'string',
              enum: ['check_in', 'meeting_reminder', 'sponsor_contact', 'milestone_celebration', 'crisis_support'],
              description: 'Type of recovery support email template'
            },
            variables: {
              type: 'object',
              description: 'Variables to fill in the template (name, meeting_name, etc.)'
            },
            personalMessage: {
              type: 'string',
              description: 'Additional personal message to include'
            }
          },
          required: ['to', 'template']
        }
      },
      {
        name: 'create_email_draft',
        description: 'Create a draft email without sending it',
        parameters: {
          type: 'object',
          properties: {
            to: {
              type: 'array',
              items: { type: 'string' },
              description: 'Recipient email addresses'
            },
            subject: {
              type: 'string',
              description: 'Email subject line'
            },
            body: {
              type: 'string',
              description: 'Email body content'
            },
            isHtml: {
              type: 'boolean',
              description: 'Whether the body is HTML format',
              default: false
            }
          },
          required: ['to', 'subject', 'body']
        }
      }
    ];
  }

  /**
   * Execute a Gmail tool
   */
  async executeGmailTool(toolName: string, parameters: any): Promise<any> {
    try {
      switch (toolName) {
        case 'send_email':
          return await this.sendEmail(parameters);
        
        case 'search_emails':
          return await this.searchEmails(parameters);
        
        case 'get_unread_emails':
          return await this.getUnreadEmails(parameters);
        
        case 'mark_email_as_read':
          return await this.markEmailAsRead(parameters);
        
        case 'mark_email_as_unread':
          return await this.markEmailAsUnread(parameters);
        
        case 'delete_email':
          return await this.deleteEmail(parameters);
        
        case 'reply_to_email':
          return await this.replyToEmail(parameters);
        
        case 'forward_email':
          return await this.forwardEmail(parameters);
        
        case 'send_recovery_support_email':
          return await this.sendRecoverySupportEmail(parameters);
        
        case 'create_email_draft':
          return await this.createEmailDraft(parameters);
        
        default:
          throw new Error(`Unknown Gmail tool: ${toolName}`);
      }
    } catch (error) {
      console.error(`Error executing Gmail tool ${toolName}:`, error);
      throw error;
    }
  }

  /**
   * Send an email
   */
  private async sendEmail(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/gmail/send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        to: params.to,
        cc: params.cc,
        bcc: params.bcc,
        subject: params.subject,
        body: params.body,
        isHtml: params.isHtml || false,
        priority: params.priority || 'normal',
        replyTo: params.replyTo,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to send email: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Search emails
   */
  private async searchEmails(params: any): Promise<any> {
    const queryParams = new URLSearchParams();
    if (params.query) queryParams.append('query', params.query);
    if (params.from) queryParams.append('from', params.from);
    if (params.to) queryParams.append('to', params.to);
    if (params.subject) queryParams.append('subject', params.subject);
    if (params.hasAttachment !== undefined) queryParams.append('hasAttachment', params.hasAttachment.toString());
    if (params.isRead !== undefined) queryParams.append('isRead', params.isRead.toString());
    if (params.isImportant !== undefined) queryParams.append('isImportant', params.isImportant.toString());
    if (params.after) queryParams.append('after', params.after);
    if (params.before) queryParams.append('before', params.before);
    if (params.maxResults) queryParams.append('maxResults', params.maxResults.toString());

    const response = await fetch(`${this.baseUrl}/api/gmail/search?${queryParams}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to search emails: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Get unread emails
   */
  private async getUnreadEmails(params: any): Promise<any> {
    return await this.searchEmails({
      isRead: false,
      maxResults: params.maxResults || 20,
      ...(params.priority === 'important' && { isImportant: true }),
    });
  }

  /**
   * Mark email as read
   */
  private async markEmailAsRead(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/gmail/${params.emailId}/read`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to mark email as read: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Mark email as unread
   */
  private async markEmailAsUnread(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/gmail/${params.emailId}/unread`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to mark email as unread: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Delete email
   */
  private async deleteEmail(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/gmail/${params.emailId}`, {
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
      throw new Error(`Failed to delete email: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Reply to email
   */
  private async replyToEmail(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/gmail/${params.emailId}/reply`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        body: params.body,
        isHtml: params.isHtml || false,
        includeOriginal: params.includeOriginal !== false,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to reply to email: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Forward email
   */
  private async forwardEmail(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/gmail/${params.emailId}/forward`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        to: params.to,
        message: params.message,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to forward email: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Send recovery support email
   */
  private async sendRecoverySupportEmail(params: any): Promise<any> {
    const templates = this.getRecoveryEmailTemplates();
    const template = templates[params.template];
    
    if (!template) {
      throw new Error(`Unknown recovery email template: ${params.template}`);
    }

    let subject = template.subject;
    let body = template.body;

    // Replace variables in template
    if (params.variables) {
      for (const [key, value] of Object.entries(params.variables)) {
        const placeholder = `{{${key}}}`;
        subject = subject.replace(new RegExp(placeholder, 'g'), String(value));
        body = body.replace(new RegExp(placeholder, 'g'), String(value));
      }
    }

    // Add personal message if provided
    if (params.personalMessage) {
      body += `\n\nPersonal Message:\n${params.personalMessage}`;
    }

    return await this.sendEmail({
      to: params.to,
      subject,
      body,
      isHtml: false,
    });
  }

  /**
   * Create email draft
   */
  private async createEmailDraft(params: any): Promise<any> {
    const response = await fetch(`${this.baseUrl}/api/gmail/drafts`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.googleApiKey && { 'Authorization': `Bearer ${this.googleApiKey}` }),
      },
      body: JSON.stringify({
        to: params.to,
        subject: params.subject,
        body: params.body,
        isHtml: params.isHtml || false,
      }),
    });

    if (!response.ok) {
      throw new Error(`Failed to create email draft: ${response.statusText}`);
    }

    return await response.json();
  }

  /**
   * Get recovery email templates
   */
  private getRecoveryEmailTemplates(): Record<string, { subject: string; body: string }> {
    return {
      check_in: {
        subject: 'Recovery Check-In - How are you doing?',
        body: `Hi {{name}},

I hope you're doing well in your recovery journey. I wanted to reach out and see how you're doing.

Remember:
- One day at a time
- You're not alone in this
- Every step forward counts

Is there anything I can help you with or any support you need right now?

Take care,
{{sender_name}}`
      },
      meeting_reminder: {
        subject: 'NA Meeting Reminder - {{meeting_name}}',
        body: `Hi {{name}},

This is a friendly reminder about the NA meeting tomorrow:

Meeting: {{meeting_name}}
Time: {{meeting_time}}
Location: {{meeting_location}}

I hope to see you there! Meetings are a great way to stay connected with your recovery community.

Take care,
{{sender_name}}`
      },
      sponsor_contact: {
        subject: 'Time to Connect with Your Sponsor',
        body: `Hi {{name}},

I wanted to remind you that it's been a while since you last connected with your sponsor. Regular contact with your sponsor is an important part of the recovery process.

Consider reaching out to:
- Share how you're doing
- Discuss any challenges you're facing
- Work on your step work
- Get support and guidance

You're doing great, and staying connected with your support network is key to long-term recovery.

Take care,
{{sender_name}}`
      },
      milestone_celebration: {
        subject: 'Congratulations on {{milestone}}!',
        body: `Hi {{name}},

Congratulations on reaching {{milestone}}! This is a significant achievement in your recovery journey.

Your commitment to recovery is inspiring, and I'm proud of the progress you've made. Remember to celebrate this milestone and acknowledge the hard work you've put in.

Keep up the great work!

With admiration,
{{sender_name}}`
      },
      crisis_support: {
        subject: 'You're Not Alone - Support is Available',
        body: `Hi {{name}},

I want you to know that you're not alone, and there are people who care about you and want to help.

If you're going through a difficult time, please remember:
- Reach out to your sponsor or support network
- Attend a meeting (there are 24/7 online meetings available)
- Call the NA helpline: 1-800-NA-HELP
- Remember that this too shall pass

You've come this far, and you have the strength to get through this. Don't hesitate to ask for help when you need it.

With care and support,
{{sender_name}}`
      }
    };
  }
}
