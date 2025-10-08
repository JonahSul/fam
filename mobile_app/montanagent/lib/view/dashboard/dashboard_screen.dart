import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/theme/app_theme.dart';
import '../../helpers/widgets/my_breadcrumb.dart';
import '../../helpers/widgets/my_card.dart';
import '../../helpers/widgets/my_flex.dart';
import '../../helpers/widgets/my_spacing.dart';
import '../../helpers/widgets/my_text.dart';
import '../../helpers/widgets/my_button.dart';
import '../layouts/layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium("Dashboard", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'Home'),
                    MyBreadcrumbItem(name: 'Dashboard', active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(16),
          Padding(
            padding: MySpacing.x(8),
            child: MyFlex(
              children: [
                MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildWelcomeCard()),
                MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildStatsCard()),
                MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildQuickActionsCard()),
                MyFlexItem(sizes: 'lg-3 md-6 sm-12', child: _buildRecentActivityCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return MyCard(
      paddingAll: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              MySpacing.width(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyLarge(
                    'Welcome back!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  MyText.bodySmall(
                    'Ready for your recovery journey?',
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ],
              ),
            ],
          ),
          MySpacing.height(16),
          MyButton.medium(
            MyText.bodyMedium('Start Chat', color: Colors.white),
            onPressed: () => Get.toNamed('/apps/chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return MyCard(
      paddingAll: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyLarge('Your Progress', style: TextStyle(fontWeight: FontWeight.w600)),
          MySpacing.height(16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    MyText.titleMedium('12', style: TextStyle(fontWeight: FontWeight.w700)),
                    MyText.bodySmall('Sessions', color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    MyText.titleMedium('8', style: TextStyle(fontWeight: FontWeight.w700)),
                    MyText.bodySmall('Goals Met', color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return MyCard(
      paddingAll: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyLarge('Quick Actions', style: TextStyle(fontWeight: FontWeight.w600)),
          MySpacing.height(16),
          Column(
            children: [
              _buildActionButton(Icons.chat, 'Start Chat', () => Get.toNamed('/apps/chat')),
              MySpacing.height(8),
              _buildActionButton(Icons.task, 'View Tasks', () => Get.toNamed('/apps/todos')),
              MySpacing.height(8),
              _buildActionButton(Icons.people, 'Find Meetings', () => Get.toNamed('/apps/meetings')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return MyCard(
      paddingAll: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyLarge('Recent Activity', style: TextStyle(fontWeight: FontWeight.w600)),
          MySpacing.height(16),
          Column(
            children: [
              _buildActivityItem('Chat session completed', '2 hours ago'),
              MySpacing.height(8),
              _buildActivityItem('New task created', '1 day ago'),
              MySpacing.height(8),
              _buildActivityItem('Meeting attended', '3 days ago'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String title, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: MySpacing.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).primaryColor),
            MySpacing.width(8),
            MyText.bodyMedium(title),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String activity, String time) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        MySpacing.width(8),
        Expanded(
          child: MyText.bodySmall(activity),
        ),
        MyText.bodySmall(
          time,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
        ),
      ],
    );
  }
}
