import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// BMLT (Basic Meeting List Toolbox) Service
/// Provides access to real-time NA meeting information
class BmltService extends ChangeNotifier {
  final String _baseUrl;
  bool _isLoading = false;

  BmltService({String? baseUrl}) : _baseUrl = baseUrl ?? 'http://localhost:3000';

  bool get isLoading => _isLoading;

  /// Search for meetings with various criteria
  Future<List<Meeting>> searchMeetings({
    String? location,
    int? weekday,
    String? format,
    int? limit,
    int? radius,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔍 Searching meetings with params: location=$location, weekday=$weekday, format=$format');

      final response = await http.post(
        Uri.parse('$_baseUrl/search-meetings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'location': location,
          'weekday': weekday,
          'format': format,
          'limit': limit ?? 50,
          'radius': radius,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Meeting search timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meetingsData = data['meetings'] as List<dynamic>? ?? [];
        
        final meetings = meetingsData.map((meetingData) => 
            Meeting.fromMap(meetingData as Map<String, dynamic>)).toList();
        
        debugPrint('✅ Found ${meetings.length} meetings');
        return meetings;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Meeting search failed: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Error searching meetings: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get today's meetings
  Future<List<Meeting>> getTodaysMeetings({String? location}) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📅 Getting today\'s meetings for location: ${location ?? 'all'}');

      final uri = Uri.parse('$_baseUrl/meetings/today');
      final uriWithQuery = location != null 
          ? uri.replace(queryParameters: {'location': location})
          : uri;

      final response = await http.get(
        uriWithQuery,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Meeting search timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meetingsData = data['meetings'] as List<dynamic>? ?? [];
        
        final meetings = meetingsData.map((meetingData) => 
            Meeting.fromMap(meetingData as Map<String, dynamic>)).toList();
        
        debugPrint('✅ Found ${meetings.length} meetings for today');
        return meetings;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get today\'s meetings: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Error getting today\'s meetings: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get meetings for a specific day of the week
  Future<List<Meeting>> getMeetingsForDay(int weekday, {String? location}) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📅 Getting meetings for weekday $weekday for location: ${location ?? 'all'}');

      final uri = Uri.parse('$_baseUrl/meetings/day/$weekday');
      final uriWithQuery = location != null 
          ? uri.replace(queryParameters: {'location': location})
          : uri;

      final response = await http.get(
        uriWithQuery,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Meeting search timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meetingsData = data['meetings'] as List<dynamic>? ?? [];
        
        final meetings = meetingsData.map((meetingData) => 
            Meeting.fromMap(meetingData as Map<String, dynamic>)).toList();
        
        debugPrint('✅ Found ${meetings.length} meetings for weekday $weekday');
        return meetings;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get meetings for day: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Error getting meetings for day: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get meetings near a location
  Future<List<Meeting>> getMeetingsNearLocation(String location, {int radius = 25}) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📍 Getting meetings near $location within $radius miles');

      final uri = Uri.parse('$_baseUrl/meetings/near');
      final uriWithQuery = uri.replace(queryParameters: {
        'location': location,
        'radius': radius.toString(),
      });

      final response = await http.get(
        uriWithQuery,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Meeting search timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meetingsData = data['meetings'] as List<dynamic>? ?? [];
        
        final meetings = meetingsData.map((meetingData) => 
            Meeting.fromMap(meetingData as Map<String, dynamic>)).toList();
        
        debugPrint('✅ Found ${meetings.length} meetings near $location');
        return meetings;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get meetings near location: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Error getting meetings near location: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get meetings by format
  Future<List<Meeting>> getMeetingsByFormat(String format, {String? location}) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🏷️ Getting $format meetings for location: ${location ?? 'all'}');

      final uri = Uri.parse('$_baseUrl/meetings/format/$format');
      final uriWithQuery = location != null 
          ? uri.replace(queryParameters: {'location': location})
          : uri;

      final response = await http.get(
        uriWithQuery,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Meeting search timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meetingsData = data['meetings'] as List<dynamic>? ?? [];
        
        final meetings = meetingsData.map((meetingData) => 
            Meeting.fromMap(meetingData as Map<String, dynamic>)).toList();
        
        debugPrint('✅ Found ${meetings.length} $format meetings');
        return meetings;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Failed to get meetings by format: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Error getting meetings by format: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get day name from weekday number
  static String getDayName(int weekday) {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[weekday - 1] ?? 'Unknown';
  }

  /// Format time for display
  static String formatTime(String timeString) {
    final time = timeString.split(':');
    if (time.length >= 2) {
      final hours = int.tryParse(time[0]) ?? 0;
      final minutes = time[1];
      final ampm = hours >= 12 ? 'PM' : 'AM';
      final displayHours = hours % 12 == 0 ? 12 : hours % 12;
      return '$displayHours:$minutes $ampm';
    }
    return timeString;
  }
}

/// Meeting model
class Meeting {
  final String id;
  final String name;
  final String time;
  final String duration;
  final String location;
  final String address;
  final String city;
  final String province;
  final String comments;
  final List<String> formats;
  final double? distance;

  Meeting({
    required this.id,
    required this.name,
    required this.time,
    required this.duration,
    required this.location,
    required this.address,
    required this.city,
    required this.province,
    required this.comments,
    required this.formats,
    this.distance,
  });

  factory Meeting.fromMap(Map<String, dynamic> data) {
    return Meeting(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      time: data['time'] ?? '',
      duration: data['duration'] ?? '',
      location: data['location'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      province: data['province'] ?? '',
      comments: data['comments'] ?? '',
      formats: List<String>.from(data['formats'] ?? []),
      distance: data['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'time': time,
      'duration': duration,
      'location': location,
      'address': address,
      'city': city,
      'province': province,
      'comments': comments,
      'formats': formats,
      'distance': distance,
    };
  }

  /// Get formatted time for display
  String get formattedTime => BmltService.formatTime(time);

  /// Get full address
  String get fullAddress {
    final parts = [address, city, province].where((part) => part.isNotEmpty).toList();
    return parts.join(', ');
  }

  /// Get meeting summary
  String get summary {
    return '$name at $formattedTime - $fullAddress';
  }
}
