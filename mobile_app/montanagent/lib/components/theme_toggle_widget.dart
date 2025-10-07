import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/render_quality_service.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final EdgeInsetsGeometry? padding;

  const ThemeToggleWidget({
    super.key,
    this.showLabel = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel)
            Text(
              'Theme Controls',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dark Mode Toggle
              _buildToggleButton(
                context: context,
                icon: Theme.of(context).brightness == Brightness.dark 
                    ? Icons.light_mode 
                    : Icons.dark_mode,
                isActive: Theme.of(context).brightness == Brightness.dark,
                onTap: () {
                  // Toggle theme mode - this would typically be handled by a theme provider
                },
                tooltip: 'Toggle Dark Mode',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class ThemeSettingsDialog extends StatelessWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Theme Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dark Mode Toggle
            ListTile(
              leading: Icon(
                Theme.of(context).brightness == Brightness.dark 
                    ? Icons.dark_mode 
                    : Icons.light_mode,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                Theme.of(context).brightness == Brightness.dark
                    ? 'Dark theme enabled'
                    : 'Light theme enabled',
              ),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  // Toggle theme mode - this would typically be handled by a theme provider
                },
              ),
            ),

            SizedBox.shrink(),

            // Render Quality Controls
            Consumer<RenderQualityService>(
              builder: (context, renderQualityService, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Render Quality',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox.shrink(),
                    ...RenderQuality.values.map((quality) {
                      return RadioListTile<RenderQuality>(
                        title: Text(quality.displayName),
                        subtitle: Text(quality.description),
                        value: quality,
                        groupValue: renderQualityService.currentQuality,
                        onChanged: (value) async {
                          if (value != null) {
                            await renderQualityService.setQuality(value);
                          }
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ],
                );
              },
            ),

            SizedBox.shrink(),

            // Feature descriptions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liquid Glass Renderer Features:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox.shrink(),
                  const Text('• Advanced shader-based glass effects'),
                  const Text('• True liquid glass rendering'),
                  const Text('• Excellent performance'),
                  const Text('• Multiple shape support'),
                  const Text('• Blending layers'),
                  const Text('• Highly customizable'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
    );
  }
}
