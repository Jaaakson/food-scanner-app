import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';

class ThemeModeCard extends StatelessWidget {
  const ThemeModeCard({
    super.key,
    required this.isDarkModeEnabled,
    required this.onChanged,
  });

  final bool isDarkModeEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      showShadow: false,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              isDarkModeEnabled ? LucideIcons.moon : LucideIcons.sun,
              size: 21,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Dummy toggle for UI preview',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkModeEnabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}