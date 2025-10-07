import 'package:flutter/material.dart';
import '../services/agent_mode_service.dart';

/// Widget to display tool execution status and results
class ToolExecutionWidget extends StatelessWidget {
  final ToolExecution execution;
  final VoidCallback? onRetry;
  final VoidCallback? onViewDetails;

  const ToolExecutionWidget({
    super.key,
    required this.execution,
    this.onRetry,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with tool name and status
            Row(
              children: [
                _buildStatusIcon(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getToolDisplayName(execution.toolName),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (execution.isFailed && onRetry != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    onPressed: onRetry,
                    tooltip: 'Retry',
                  ),
                if (onViewDetails != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline, size: 16),
                    onPressed: onViewDetails,
                    tooltip: 'View Details',
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Status and timestamp
            Row(
              children: [
                Text(
                  _getStatusDisplayName(execution.status),
                  style: TextStyle(
                    color: _getStatusColor(execution.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(execution.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            // Error message if failed
            if (execution.isFailed && execution.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        execution.error!,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Result preview if completed
            if (execution.isCompleted && execution.result != null) ...[
              const SizedBox(height: 8),
              _buildResultPreview(context),
            ],
            
            // Progress indicator if executing
            if (execution.isExecuting) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData iconData;
    Color iconColor;

    switch (execution.status) {
      case ToolExecutionStatus.pending:
        iconData = Icons.schedule;
        iconColor = Colors.orange;
        break;
      case ToolExecutionStatus.executing:
        iconData = Icons.sync;
        iconColor = Colors.blue;
        break;
      case ToolExecutionStatus.completed:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case ToolExecutionStatus.failed:
        iconData = Icons.error;
        iconColor = Colors.red;
        break;
    }

    return Icon(iconData, color: iconColor, size: 16);
  }

  Widget _buildResultPreview(BuildContext context) {
    final result = execution.result;
    
    if (result is Map<String, dynamic>) {
      // Handle different result types
      if (result.containsKey('meetings')) {
        final meetings = result['meetings'] as List?;
        return _buildMeetingsPreview(context, meetings?.length ?? 0);
      } else if (result.containsKey('message')) {
        return _buildMessagePreview(context, result['message']);
      } else if (result.containsKey('eventId')) {
        return _buildEventPreview(context, result);
      }
    }
    
    // Generic result preview
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tool executed successfully',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingsPreview(BuildContext context, int meetingCount) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Found $meetingCount NA meetings',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagePreview(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.email, color: Colors.green[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventPreview(BuildContext context, Map<String, dynamic> event) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.event, color: Colors.purple[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Calendar event created: ${event['title'] ?? 'Untitled'}',
              style: TextStyle(
                color: Colors.purple[700],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getToolDisplayName(String toolName) {
    switch (toolName) {
      case 'search_meetings':
        return 'Searching NA Meetings';
      case 'get_todays_meetings':
        return 'Getting Today\'s Meetings';
      case 'get_user_todos':
        return 'Loading TODOs';
      case 'complete_todo':
        return 'Completing TODO';
      case 'create_calendar_event':
        return 'Creating Calendar Event';
      case 'send_email':
        return 'Sending Email';
      case 'create_meet_session':
        return 'Creating Meet Session';
      case 'schedule_na_meeting':
        return 'Scheduling NA Meeting';
      default:
        return toolName.replaceAll('_', ' ').split(' ').map((word) => 
            word.isEmpty ? word : word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  String _getStatusDisplayName(ToolExecutionStatus status) {
    switch (status) {
      case ToolExecutionStatus.pending:
        return 'Pending';
      case ToolExecutionStatus.executing:
        return 'Executing...';
      case ToolExecutionStatus.completed:
        return 'Completed';
      case ToolExecutionStatus.failed:
        return 'Failed';
    }
  }

  Color _getStatusColor(ToolExecutionStatus status) {
    switch (status) {
      case ToolExecutionStatus.pending:
        return Colors.orange;
      case ToolExecutionStatus.executing:
        return Colors.blue;
      case ToolExecutionStatus.completed:
        return Colors.green;
      case ToolExecutionStatus.failed:
        return Colors.red;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

/// Widget to display multiple tool executions
class ToolExecutionsList extends StatelessWidget {
  final List<ToolExecution> executions;
  final Function(ToolExecution)? onRetry;
  final Function(ToolExecution)? onViewDetails;

  const ToolExecutionsList({
    super.key,
    required this.executions,
    this.onRetry,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (executions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Agent Actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        ...executions.map((execution) => ToolExecutionWidget(
          execution: execution,
          onRetry: onRetry != null ? () => onRetry!(execution) : null,
          onViewDetails: onViewDetails != null ? () => onViewDetails!(execution) : null,
        )),
      ],
    );
  }
}
