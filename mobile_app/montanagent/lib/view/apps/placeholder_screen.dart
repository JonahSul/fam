import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/widgets/my_spacing.dart';
import '../../helpers/widgets/my_text.dart';
import '../../helpers/widgets/my_card.dart';
import '../../helpers/widgets/my_button.dart';
import '../layouts/layout.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(16),
            child: MyText.titleMedium(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          MySpacing.height(16),
          Expanded(
            child: Center(
              child: MyCard(
                paddingAll: 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction,
                      size: 64,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    MySpacing.height(16),
                    MyText.titleMedium(
                      'Coming Soon',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    MySpacing.height(8),
                    MyText.bodyMedium(
                      description,
                      textAlign: TextAlign.center,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    MySpacing.height(24),
                    MyButton.medium(
                      MyText.bodyMedium('Go to Chat', color: Colors.white),
                      onPressed: () => Get.toNamed('/apps/chat'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
