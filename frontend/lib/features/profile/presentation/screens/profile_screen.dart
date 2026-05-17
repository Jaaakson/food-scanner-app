import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_page_section.dart';
import '../../../../shared/widgets/app_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/theme_mode_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkModeEnabled = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkModeEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Dark mode preview toggle enabled.'
              : 'Dark mode preview toggle disabled.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName will be implemented later.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxxl,
          ),
          children: [
            const AnimatedPageSection(
              delay: Duration(milliseconds: 40),
              child: ProfileHeader(
                userName: AppConstants.defaultUserName,
                subtitle: 'AI Food Scanner Demo',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const AnimatedPageSection(
              delay: Duration(milliseconds: 90),
              child: Row(
                children: [
                  Expanded(
                    child: ProfileStatCard(
                      label: 'Daily Target',
                      value: '2200',
                      unit: 'kcal',
                      icon: LucideIcons.flame,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ProfileStatCard(
                      label: 'Mode',
                      value: 'MVP',
                      unit: 'demo',
                      icon: LucideIcons.layers,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedPageSection(
              delay: const Duration(milliseconds: 140),
              child: ThemeModeCard(
                isDarkModeEnabled: _isDarkModeEnabled,
                onChanged: _toggleDarkMode,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedPageSection(
              delay: const Duration(milliseconds: 190),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ProfileMenuTile(
                      icon: LucideIcons.clipboardList,
                      title: 'Nutrition Facts',
                      subtitle: 'Manage nutrition reference data',
                      onTap: () => _showComingSoon('Nutrition Facts'),
                    ),
                    const _ProfileMenuDivider(),
                    ProfileMenuTile(
                      icon: LucideIcons.target,
                      title: 'Set Plan',
                      subtitle: 'Configure calorie and macro goals',
                      onTap: () => _showComingSoon('Set Plan'),
                    ),
                    const _ProfileMenuDivider(),
                    ProfileMenuTile(
                      icon: LucideIcons.history,
                      title: 'History',
                      subtitle: 'View saved scan results',
                      onTap: () => _showComingSoon('History'),
                    ),
                    const _ProfileMenuDivider(),
                    ProfileMenuTile(
                      icon: LucideIcons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences and account options',
                      onTap: () => _showComingSoon('Settings'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuDivider extends StatelessWidget {
  const _ProfileMenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: AppSpacing.lg,
      endIndent: AppSpacing.lg,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
    );
  }
}