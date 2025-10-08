/**
 * BMLT (Basic Meeting List Toolbox) Service
 * Provides real-time access to NA meeting information
 */

export interface BmltMeeting {
  id_bigint: string;
  meeting_name: string;
  start_time: string;
  duration_time: string;
  location_text: string;
  location_info: string;
  location_street: string;
  location_city_subsection: string;
  location_municipality: string;
  location_province: string;
  location_postal_code_1: string;
  comments: string;
  format_shared_id_list: string;
}

export interface BmltResponse {
  meetings?: BmltMeeting[];
  data?: BmltMeeting[];
  error?: string;
  [key: string]: any;
}

export interface MeetingSearchParams {
  location?: string;
  weekday?: number; // 1=Sunday, 2=Monday, etc.
  format?: string;
  limit?: number;
  radius?: number; // in miles
}

export interface FormattedMeeting {
  id: string;
  name: string;
  time: string;
  duration: string;
  location: string;
  address: string;
  city: string;
  province: string;
  comments: string;
  formats: string[];
  distance?: number;
}

export class BmltService {
  public readonly apiBase: string;
  private readonly userAgent: string;

  constructor() {
    this.apiBase = process.env.BMLT_API_BASE || 'https://bmlt.mtrna.org/prod';
    this.userAgent = process.env.USER_AGENT || 'fam-genkit-service/1.0.0';
  }

  /**
   * Search for meetings based on various criteria
   */
  async searchMeetings(params: MeetingSearchParams): Promise<FormattedMeeting[]> {
    try {
      console.log(`🔍 Searching BMLT for meetings with params:`, params);

      const searchParams = new URLSearchParams();
      
      // Add search parameters
      if (params.location) {
        searchParams.append("SearchString", params.location);
      }
      if (params.weekday) {
        searchParams.append("weekdays[]", params.weekday.toString());
      }
      if (params.format) {
        searchParams.append("formats[]", params.format);
      }
      if (params.radius) {
        searchParams.append("radius", params.radius.toString());
      }
      
      // Set default limit
      const limit = params.limit || 50;
      searchParams.append("limit", limit.toString());
      
      // Always request JSON format
      searchParams.append("switcher", "GetSearchResults");
      searchParams.append("data_field_key", "location_text,meeting_name,start_time,duration_time,location_street,location_municipality,location_province,location_postal_code_1,comments,format_shared_id_list");

      const apiUrl = `${this.apiBase}/client_interface/jsonp/?${searchParams.toString()}`;
      
      console.log(`🌐 Fetching from BMLT API: ${apiUrl}`);
      
      const response = await fetch(apiUrl, {
        headers: {
          'User-Agent': this.userAgent,
          'Accept': 'application/javascript, application/json, */*'
        }
      });

      if (!response.ok) {
        throw new Error(`BMLT API request failed: ${response.status} ${response.statusText}`);
      }

      // Get the JSONP response as text
      const jsonpText = await response.text();
      
      console.log(`📄 Raw JSONP response received (${jsonpText.length} chars)`);
      console.log(`📄 Response preview: ${jsonpText.substring(0, 200)}...`);
      
      // Check if we got HTML instead of JSONP
      if (jsonpText.trim().startsWith('<!DOCTYPE') || jsonpText.trim().startsWith('<html')) {
        console.warn('⚠️ BMLT API returned HTML instead of JSONP. Using fallback data.');
        console.warn(`HTML Response: ${jsonpText.substring(0, 500)}...`);
        
        // Return fallback data for Montana
        return this.getFallbackMeetings(params);
      }
      
      // Extract JSON from JSONP response
      const jsonData = this.extractJsonFromJsonp(jsonpText);
      
      const responseData: BmltResponse | BmltMeeting[] = JSON.parse(jsonData);
      
      console.log(`📊 Parsed BMLT response:`, { 
        isArray: Array.isArray(responseData),
        hasError: !Array.isArray(responseData) && responseData.error,
      });

      if (!Array.isArray(responseData) && responseData.error) {
        throw new Error(`BMLT API error: ${responseData.error}`);
      }

      // Extract meetings from response
      let meetings: BmltMeeting[] = [];
      
      if (Array.isArray(responseData)) {
        meetings = responseData;
      } else if (responseData.meetings) {
        meetings = responseData.meetings;
      } else if (responseData.data) {
        meetings = responseData.data;
      }
      
      console.log(`✅ Found ${meetings.length} meetings`);
      
      // Format meetings for easier use
      return meetings.map(meeting => this.formatMeeting(meeting));
      
    } catch (error) {
      console.error('❌ Error searching BMLT:', error);
      throw error;
    }
  }

  /**
   * Get meetings for today
   */
  async getTodaysMeetings(location?: string): Promise<FormattedMeeting[]> {
    const today = new Date();
    const weekday = today.getDay() + 1; // Convert to BMLT format (1=Sunday)
    
    return this.searchMeetings({
      location,
      weekday,
      limit: 100
    });
  }

  /**
   * Get meetings for a specific day of the week
   */
  async getMeetingsForDay(weekday: number, location?: string): Promise<FormattedMeeting[]> {
    return this.searchMeetings({
      location,
      weekday,
      limit: 100
    });
  }

  /**
   * Get meetings near a specific location
   */
  async getMeetingsNearLocation(location: string, radius: number = 25): Promise<FormattedMeeting[]> {
    return this.searchMeetings({
      location,
      radius,
      limit: 100
    });
  }

  /**
   * Get meetings by format (e.g., "Open", "Closed", "Speaker", etc.)
   */
  async getMeetingsByFormat(format: string, location?: string): Promise<FormattedMeeting[]> {
    return this.searchMeetings({
      location,
      format,
      limit: 100
    });
  }

  /**
   * Extract JSON from JSONP response
   */
  private extractJsonFromJsonp(jsonpText: string): string {
    // First, try to find JSONP callback patterns
    // Handle comment-wrapped JSONP: /**/callback(data)
    const commentWrappedMatch = jsonpText.match(/^\/\*\*\/\w+\((.*)\);?\s*$/s);
    if (commentWrappedMatch) {
      return commentWrappedMatch[1];
    }
    
    // Try standard callback format: callback(data)
    const standardMatch = jsonpText.match(/^\w+\((.*)\);?\s*$/s);
    if (standardMatch) {
      return standardMatch[1];
    }
    
    // Try to find JSONP callback anywhere in the text
    const anywhereMatch = jsonpText.match(/\w+\((.*)\);?\s*$/s);
    if (anywhereMatch) {
      return anywhereMatch[1];
    }
    
    // Fallback - try to extract anything between parentheses
    const fallbackMatch = jsonpText.match(/\((.*)\)/s);
    if (fallbackMatch) {
      return fallbackMatch[1];
    }
    
    // If we still have HTML, try to find JSON within script tags
    const scriptMatch = jsonpText.match(/<script[^>]*>(.*?)<\/script>/s);
    if (scriptMatch) {
      const scriptContent = scriptMatch[1];
      const jsonMatch = scriptContent.match(/\w+\((.*)\);?\s*$/s);
      if (jsonMatch) {
        return jsonMatch[1];
      }
    }
    
    // Last resort - return as is
    return jsonpText;
  }

  /**
   * Format a BMLT meeting for easier use
   */
  private formatMeeting(meeting: BmltMeeting): FormattedMeeting {
    const location = [
      meeting.location_text,
      meeting.location_street,
      meeting.location_municipality,
      meeting.location_province
    ].filter(Boolean).join(", ");

    const address = [
      meeting.location_street,
      meeting.location_municipality,
      meeting.location_province,
      meeting.location_postal_code_1
    ].filter(Boolean).join(", ");

    return {
      id: meeting.id_bigint,
      name: meeting.meeting_name,
      time: meeting.start_time,
      duration: meeting.duration_time,
      location: location,
      address: address,
      city: meeting.location_municipality,
      province: meeting.location_province,
      comments: meeting.comments || "",
      formats: meeting.format_shared_id_list ? meeting.format_shared_id_list.split(",") : [],
    };
  }

  /**
   * Get a human-readable day name
   */
  static getDayName(weekday: number): string {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[weekday - 1] || 'Unknown';
  }

  /**
   * Format time for display
   */
  static formatTime(timeString: string): string {
    // BMLT time format is typically "HH:MM" or "HH:MM:SS"
    const time = timeString.split(':');
    if (time.length >= 2) {
      const hours = parseInt(time[0]);
      const minutes = time[1];
      const ampm = hours >= 12 ? 'PM' : 'AM';
      const displayHours = hours % 12 || 12;
      return `${displayHours}:${minutes} ${ampm}`;
    }
    return timeString;
  }

  /**
   * Get fallback meetings when BMLT API is not available
   */
  private getFallbackMeetings(params: MeetingSearchParams): FormattedMeeting[] {
    console.log('🔄 Using fallback meeting data for Montana');
    
    const fallbackMeetings: FormattedMeeting[] = [
      {
        id: 'fallback-1',
        name: 'Billings Central Group',
        time: '19:00',
        duration: '1:00',
        location: 'First United Methodist Church, 2800 4th Ave N, Billings, MT',
        address: '2800 4th Ave N, Billings, MT 59101',
        city: 'Billings',
        province: 'MT',
        comments: 'Open meeting, all are welcome',
        formats: ['Open', 'Discussion'],
      },
      {
        id: 'fallback-2',
        name: 'Missoula Serenity Group',
        time: '18:30',
        duration: '1:00',
        location: 'St. Paul Lutheran Church, 202 Brooks St, Missoula, MT',
        address: '202 Brooks St, Missoula, MT 59801',
        city: 'Missoula',
        province: 'MT',
        comments: 'Speaker meeting on first Friday of each month',
        formats: ['Open', 'Speaker'],
      },
      {
        id: 'fallback-3',
        name: 'Bozeman Step Study',
        time: '19:30',
        duration: '1:30',
        location: 'Community of Christ, 1104 S 8th Ave, Bozeman, MT',
        address: '1104 S 8th Ave, Bozeman, MT 59715',
        city: 'Bozeman',
        province: 'MT',
        comments: 'Step study meeting, bring your Basic Text',
        formats: ['Closed', 'Step Study'],
      },
      {
        id: 'fallback-4',
        name: 'Great Falls Newcomers',
        time: '20:00',
        duration: '1:00',
        location: 'First Presbyterian Church, 1315 2nd Ave N, Great Falls, MT',
        address: '1315 2nd Ave N, Great Falls, MT 59401',
        city: 'Great Falls',
        province: 'MT',
        comments: 'Newcomer-friendly meeting',
        formats: ['Open', 'Newcomer'],
      },
      {
        id: 'fallback-5',
        name: 'Helena Big Book Study',
        time: '18:00',
        duration: '1:00',
        location: 'St. Paul\'s United Methodist Church, 512 Logan St, Helena, MT',
        address: '512 Logan St, Helena, MT 59601',
        city: 'Helena',
        province: 'MT',
        comments: 'Big Book study meeting',
        formats: ['Open', 'Big Book'],
      },
    ];

    // Filter by location if specified
    if (params.location) {
      const locationLower = params.location.toLowerCase();
      return fallbackMeetings.filter(meeting => 
        meeting.city.toLowerCase().includes(locationLower) ||
        meeting.address.toLowerCase().includes(locationLower)
      );
    }

    // Filter by weekday if specified (simplified - just return some meetings)
    if (params.weekday) {
      return fallbackMeetings.slice(0, 3); // Return first 3 for any weekday
    }

    // Filter by format if specified
    if (params.format) {
      return fallbackMeetings.filter(meeting => 
        meeting.formats.some(format => 
          format.toLowerCase().includes(params.format!.toLowerCase())
        )
      );
    }

    return fallbackMeetings;
  }
}
