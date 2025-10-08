import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bmlt_service.dart';
import '../components/glass/glass.dart';

class MeetingSearchScreen extends StatefulWidget {
  const MeetingSearchScreen({super.key});

  @override
  State<MeetingSearchScreen> createState() => _MeetingSearchScreenState();
}

class _MeetingSearchScreenState extends State<MeetingSearchScreen> {
  final _locationController = TextEditingController();
  final _radiusController = TextEditingController(text: '25');
  final GlobalKey _backgroundKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  String _selectedFormat = 'All';
  int? _selectedWeekday;
  List<Meeting> _meetings = [];
  String? _errorMessage;

  final List<String> _formats = [
    'All',
    'Open',
    'Closed',
    'Speaker',
    'Discussion',
    'Step Study',
    'Big Book',
    'Newcomer',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _radiusController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Meetings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Search Filters
            Card(
              child: Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location input
                    TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (city, zip code, etc.)',
                        hintText: 'e.g., Missoula, MT or 59801',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),

                    SizedBox.shrink(),

                    // Format and weekday row
                    Row(
                      children: [
                        // Format dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedFormat,
                            decoration: const InputDecoration(
                              labelText: 'Format',
                              border: OutlineInputBorder(),
                            ),
                            items: _formats.map((format) {
                              return DropdownMenuItem(
                                value: format,
                                child: Text(format),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedFormat = value!;
                              });
                            },
                          ),
                        ),

                        SizedBox.shrink(),

                        // Weekday dropdown
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: _selectedWeekday,
                            decoration: const InputDecoration(
                              labelText: 'Day',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('Any Day'),
                              ),
                              ...List.generate(7, (index) {
                                final weekday = index + 1;
                                return DropdownMenuItem(
                                  value: weekday,
                                  child: Text(BmltService.getDayName(weekday)),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedWeekday = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox.shrink(),

                    // Search buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _searchMeetings,
                            icon: const Icon(Icons.search),
                            label: const Text('Search'),
                          ),
                        ),
                        SizedBox.shrink(),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _getTodaysMeetings,
                            icon: const Icon(Icons.today),
                            label: const Text('Today'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox.shrink(),

            // Results
            Expanded(
              child: _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            SizedBox.shrink(),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox.shrink(),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox.shrink(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox.shrink(),
            Text(
              'No meetings found',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
            SizedBox.shrink(),
            Text(
              'Try adjusting your search criteria',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: _meetings.length,
      itemBuilder: (context, index) {
        final meeting = _meetings[index];
        return _buildMeetingCard(meeting);
      },
    );
  }

  Widget _buildMeetingCard(Meeting meeting) {
    return GlassCard(
      backgroundKey: _backgroundKey,
      scrollController: _scrollController,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting name and time
            Row(
              children: [
                Expanded(
                  child: Text(
                    meeting.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    meeting.formattedTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox.shrink(),
            
            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox.shrink(),
                Expanded(
                  child: Text(
                    meeting.fullAddress,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            
            // Duration
            if (meeting.duration.isNotEmpty) ...[
              SizedBox.shrink(),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox.shrink(),
                  Text(
                    'Duration: ${meeting.duration}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            
            // Formats
            if (meeting.formats.isNotEmpty) ...[
              SizedBox.shrink(),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: meeting.formats.map((format) => Chip(
                  label: Text(
                    format,
                    style: const TextStyle(fontSize: 12),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
            
            // Comments
            if (meeting.comments.isNotEmpty) ...[
              SizedBox.shrink(),
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue[700],
                    ),
                    SizedBox.shrink(),
                    Expanded(
                      child: Text(
                        meeting.comments,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _searchMeetings() async {
    final bmltService = Provider.of<BmltService>(context, listen: false);
    
    setState(() {
      _errorMessage = null;
    });

    try {
      final meetings = await bmltService.searchMeetings(
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
        weekday: _selectedWeekday,
        format: _selectedFormat == 'All' ? null : _selectedFormat,
        limit: 50,
      );

      setState(() {
        _meetings = meetings;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _getTodaysMeetings() async {
    final bmltService = Provider.of<BmltService>(context, listen: false);
    
    setState(() {
      _errorMessage = null;
    });

    try {
      final meetings = await bmltService.getTodaysMeetings(
        location: _locationController.text.trim().isEmpty 
            ? null 
            : _locationController.text.trim(),
      );

      setState(() {
        _meetings = meetings;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }
}
