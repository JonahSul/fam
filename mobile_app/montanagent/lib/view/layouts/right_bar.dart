import 'package:flutter/material.dart';
import '../../helpers/widgets/my_spacing.dart';
import '../../helpers/widgets/my_text.dart';
import '../../helpers/widgets/my_card.dart';

class RightBar extends StatelessWidget {
  const RightBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: MySpacing.all(24),
            child:             MyText.titleMedium(
              'Activity',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // Activity Feed
          Expanded(
            child: ListView(
              padding: MySpacing.symmetric(horizontal: 16),
              children: [
                _buildActivityItem(
                  context,
                  icon: Icons.chat,
                  title: 'New message received',
                  time: '2 minutes ago',
                  color: Colors.blue,
                ),
                MySpacing.height(12),
                _buildActivityItem(
                  context,
                  icon: Icons.task_alt,
                  title: 'Task completed',
                  time: '15 minutes ago',
                  color: Colors.green,
                ),
                MySpacing.height(12),
                _buildActivityItem(
                  context,
                  icon: Icons.schedule,
                  title: 'Meeting reminder',
                  time: '1 hour ago',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    required Color color,
  }) {
    return MyCard(
      paddingAll: 12,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          MySpacing.width(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                MyText.bodySmall(
                  time,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
