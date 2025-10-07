import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(TodoStatus)? onStatusChanged;

  const TodoItemWidget({
    super.key,
    required this.todo,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      todo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: todo.status == TodoStatus.completed 
                            ? TextDecoration.lineThrough 
                            : null,
                        color: todo.status == TodoStatus.completed 
                            ? Colors.grey 
                            : null,
                      ),
                    ),
                  ),
                  _buildPriorityChip(context),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              if (todo.description.isNotEmpty) ...[
                Text(
                  todo.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: todo.status == TodoStatus.completed 
                        ? Colors.grey 
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Tags
              if (todo.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: todo.tags.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
                const SizedBox(height: 8),
              ],
              
              // AI Context
              if (todo.aiContext != null && todo.aiContext!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          todo.aiContext!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              // Footer with status and actions
              Row(
                children: [
                  // Status dropdown
                  Expanded(
                    child: DropdownButtonFormField<TodoStatus>(
                      initialValue: todo.status,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        isDense: true,
                      ),
                      items: TodoStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusDisplayName(status)),
                        );
                      }).toList(),
                      onChanged: (TodoStatus? newStatus) {
                        if (newStatus != null) {
                          onStatusChanged?.call(newStatus);
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: onEdit,
                          tooltip: 'Edit TODO',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: onDelete,
                          tooltip: 'Delete TODO',
                          color: Colors.red,
                        ),
                    ],
                  ),
                ],
              ),
              
              // Due date
              if (todo.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ${_formatDate(todo.dueDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    Color chipColor;
    switch (todo.priority) {
      case TodoPriority.low:
        chipColor = Colors.green;
        break;
      case TodoPriority.medium:
        chipColor = Colors.blue;
        break;
      case TodoPriority.high:
        chipColor = Colors.orange;
        break;
      case TodoPriority.urgent:
        chipColor = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        todo.priorityDisplayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _getStatusDisplayName(TodoStatus status) {
    switch (status) {
      case TodoStatus.pending:
        return 'Pending';
      case TodoStatus.inProgress:
        return 'In Progress';
      case TodoStatus.completed:
        return 'Completed';
      case TodoStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}
