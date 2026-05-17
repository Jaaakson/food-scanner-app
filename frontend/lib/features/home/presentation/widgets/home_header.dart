import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/icon_circle_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.secondaryContainer,
          ),
          child: Center(
            child: Text(
              userName.characters.first.toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        IconCircleButton(
          icon: LucideIcons.bell,
          onPressed: () {},
        ),
      ],
    );
  }
}