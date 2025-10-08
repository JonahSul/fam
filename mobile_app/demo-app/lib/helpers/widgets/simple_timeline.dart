import 'package:flutter/material.dart';

class Timeline extends StatelessWidget {
  final List<TimelineItem> children;
  final Color? indicatorColor;
  final double indicatorSize;
  final Color? lineColor;
  final double lineWidth;

  const Timeline({
    super.key,
    required this.children,
    this.indicatorColor,
    this.indicatorSize = 20.0,
    this.lineColor,
    this.lineWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isLast = index == children.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: indicatorSize,
                  height: indicatorSize,
                  decoration: BoxDecoration(
                    color: indicatorColor ?? Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: item.icon != null
                      ? Icon(
                          item.icon,
                          size: indicatorSize * 0.6,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: lineWidth,
                    height: 40,
                    color: lineColor ?? Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Timeline content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: item.child,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class TimelineItem {
  final Widget child;
  final IconData? icon;

  const TimelineItem({
    required this.child,
    this.icon,
  });
}
