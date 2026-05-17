import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/models/nutrition_summary.dart';
import '../../../../shared/widgets/section_header.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/home_header.dart';
import '../widgets/nutrition_metric_card.dart';
import '../widgets/week_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;

  final NutritionSummary _todayNutrition = const NutritionSummary(
    calories: 1240,
    protein: 72,
    carbs: 146,
    fats: 38,
    sugar: 24,
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedDate);

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
            const HomeHeader(
              userName: AppConstants.defaultUserName,
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              monthLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            WeekCalendar(
              selectedDate: _selectedDate,
              onDateSelected: _selectDate,
            ),
            const SizedBox(height: AppSpacing.xl),

            CalorieSummaryCard(
              consumedCalories: _todayNutrition.calories,
              targetCalories: AppConstants.dailyCalorieTarget,
            ),
            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(
              title: 'Today’s Nutrition',
            ),
            const SizedBox(height: AppSpacing.md),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.25,
              children: [
                NutritionMetricCard(
                  label: 'Protein',
                  value: Formatters.grams(_todayNutrition.protein),
                  icon: LucideIcons.dumbbell,
                  color: AppColors.protein,
                ),
                NutritionMetricCard(
                  label: 'Carbs',
                  value: Formatters.grams(_todayNutrition.carbs),
                  icon: LucideIcons.wheat,
                  color: AppColors.carbs,
                ),
                NutritionMetricCard(
                  label: 'Fats',
                  value: Formatters.grams(_todayNutrition.fats),
                  icon: LucideIcons.droplet,
                  color: AppColors.fats,
                ),
                NutritionMetricCard(
                  label: 'Sugar',
                  value: Formatters.grams(_todayNutrition.sugar),
                  icon: LucideIcons.candy,
                  color: AppColors.sugar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}