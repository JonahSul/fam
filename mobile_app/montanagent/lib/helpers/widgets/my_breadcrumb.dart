import 'package:flutter/material.dart';
import '../../theme/index.dart';

class MyBreadcrumb extends StatelessWidget {
  final List<MyBreadcrumbItem> children;

  const MyBreadcrumb({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Row(
          children: [
            if (index > 0) ...[
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
              MySpacing.width(8),
            ],
            MyText.bodySmall(
              item.name,
              color: item.active
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              fontWeight: item.active ? 600 : 400,
            ),
          ],
        );
      }).toList(),
    );
  }
}

class MyBreadcrumbItem {
  final String name;
  final bool active;

  const MyBreadcrumbItem({required this.name, this.active = false});
}
