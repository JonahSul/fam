import 'package:flutter/material.dart';
import 'my_text.dart';

class MyBreadcrumbItem {
  final String name;
  final bool active;

  MyBreadcrumbItem({required this.name, this.active = false});
}

class MyBreadcrumb extends StatelessWidget {
  final List<MyBreadcrumbItem> children;

  const MyBreadcrumb({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        
        return Row(
          children: [
            MyText.bodySmall(
              item.name,
              style: TextStyle(
                fontWeight: item.active ? FontWeight.w600 : FontWeight.w400,
                color: item.active ? Colors.blue : Colors.grey,
              ),
            ),
            if (index < children.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: MyText.bodySmall('/', color: Colors.grey),
              ),
          ],
        );
      }).toList(),
    );
  }
}