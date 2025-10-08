import 'package:flutter/material.dart';
import '../services/agent_mode_service.dart';

/// Toggle widget for enabling/disabling agent mode
class AgentModeToggle extends StatelessWidget {
  final AgentModeService agentModeService;
  final VoidCallback? onToggle;

  const AgentModeToggle({
    super.key,
    required this.agentModeService,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: agentModeService,
      builder: (context, child) {
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  agentModeService.isEnabled ? Icons.smart_toy : Icons.smart_toy_outlined,
                  color: agentModeService.isEnabled ? Colors.blue : Colors.grey,
                ),
                SizedBox.shrink(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agent Mode',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        agentModeService.isEnabled 
                            ? 'AI can execute tools to help complete your TODOs'
                            : 'AI provides suggestions only',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                  Switch(
                  value: agentModeService.isEnabled,
                  onChanged: (value) async {
                    await agentModeService.setEnabled(value);
                    onToggle?.call();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Compact agent mode indicator
class AgentModeIndicator extends StatelessWidget {
  final AgentModeService agentModeService;
  final VoidCallback? onTap;

  const AgentModeIndicator({
    super.key,
    required this.agentModeService,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: agentModeService,
      builder: (context, child) {
        if (!agentModeService.isEnabled) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.smart_toy,
                  size: 16,
                  color: Colors.blue[700],
                ),
                SizedBox.shrink(),
                Text(
                  'Agent Mode',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
                if (agentModeService.isProcessing) ...[
                  SizedBox.shrink(),
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Agent mode status dialog
class AgentModeStatusDialog extends StatelessWidget {
  final AgentModeService agentModeService;

  const AgentModeStatusDialog({
    super.key,
    required this.agentModeService,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smart_toy,
                  color: agentModeService.isEnabled ? Colors.blue : Colors.grey,
                ),
                SizedBox.shrink(),
                Text(
                  'Agent Mode Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox.shrink(),
            
            // Status
            _buildStatusRow(
              context,
              'Status',
              agentModeService.isEnabled ? 'Enabled' : 'Disabled',
              agentModeService.isEnabled ? Colors.green : Colors.grey,
            ),
            
            // Processing status
            if (agentModeService.isProcessing)
              _buildStatusRow(
                context,
                'Processing',
                'AI is executing tools...',
                Colors.blue,
              ),
            
            // Active executions
            _buildStatusRow(
              context,
              'Active Executions',
              '${agentModeService.activeExecutions.length}',
              Colors.orange,
            ),
            
            // Total executions
            _buildStatusRow(
              context,
              'Total Executions',
              '${agentModeService.executionHistory.length}',
              Colors.grey,
            ),
            
            SizedBox.shrink(),
            
            // Description
            Text(
              agentModeService.isEnabled
                  ? 'Agent mode allows the AI to execute tools and take actions on your behalf to help complete TODO items and support your recovery journey.'
                  : 'Enable agent mode to allow the AI to execute tools and take actions on your behalf.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox.shrink(),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                if (!agentModeService.isEnabled)
                  ElevatedButton(
                    onPressed: () async {
                      await agentModeService.setEnabled(true);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Enable'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Agent mode configuration dialog
class AgentModeConfigDialog extends StatefulWidget {
  final AgentModeService agentModeService;

  const AgentModeConfigDialog({
    super.key,
    required this.agentModeService,
  });

  @override
  State<AgentModeConfigDialog> createState() => _AgentModeConfigDialogState();
}

class _AgentModeConfigDialogState extends State<AgentModeConfigDialog> {
  bool _enabled = false;
  bool _requireConfirmation = false;
  bool _autoExecute = true;
  int _maxConcurrentExecutions = 3;

  @override
  void initState() {
    super.initState();
    _enabled = widget.agentModeService.isEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agent Mode Configuration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox.shrink(),
            
            // Enable/Disable
                  SwitchListTile(
              title: const Text('Enable Agent Mode'),
              subtitle: const Text('Allow AI to execute tools on your behalf'),
              value: _enabled,
              onChanged: (value) {
                setState(() {
                  _enabled = value;
                });
              },
            ),
            
            if (_enabled) ...[
              const Divider(),
              
              // Require confirmation
                  SwitchListTile(
                title: const Text('Require Confirmation'),
                subtitle: const Text('Ask before executing tools'),
                value: _requireConfirmation,
                onChanged: (value) {
                  setState(() {
                    _requireConfirmation = value;
                  });
                },
              ),
              
              // Auto execute
                  SwitchListTile(
                title: const Text('Auto Execute'),
                subtitle: const Text('Automatically execute approved tools'),
                value: _autoExecute,
                onChanged: (value) {
                  setState(() {
                    _autoExecute = value;
                  });
                },
              ),
              
              // Max concurrent executions
              ListTile(
                title: const Text('Max Concurrent Executions'),
                subtitle: Text('$_maxConcurrentExecutions'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _maxConcurrentExecutions > 1
                          ? () {
                              setState(() {
                                _maxConcurrentExecutions--;
                              });
                            }
                          : null,
                    ),
                    Text('$_maxConcurrentExecutions'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _maxConcurrentExecutions < 10
                          ? () {
                              setState(() {
                                _maxConcurrentExecutions++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
            
            SizedBox.shrink(),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await widget.agentModeService.updateConfiguration(
                      enabled: _enabled,
                      requireUserConfirmation: _requireConfirmation,
                      autoExecute: _autoExecute,
                      maxConcurrentExecutions: _maxConcurrentExecutions,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
