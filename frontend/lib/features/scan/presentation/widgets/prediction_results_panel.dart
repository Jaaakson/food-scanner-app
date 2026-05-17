import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../models/food_prediction.dart';

class PredictionResultsPanel extends StatelessWidget {
  const PredictionResultsPanel({
    super.key,
    required this.predictions,
    required this.selectedPrediction,
    required this.onPredictionSelected,
    required this.onClearSelection,
    required this.onSavePressed,
    required this.onScanAgainPressed,
  });

  final List<FoodPrediction> predictions;
  final FoodPrediction? selectedPrediction;
  final ValueChanged<FoodPrediction> onPredictionSelected;
  final VoidCallback onClearSelection;
  final VoidCallback onSavePressed;
  final VoidCallback onScanAgainPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activePrediction = selectedPrediction;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 46,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activePrediction == null
                          ? 'Top Predictions'
                          : activePrediction.name,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          size: 15,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'AI Result',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (activePrediction == null)
                _PredictionList(
                  predictions: predictions,
                  onPredictionSelected: onPredictionSelected,
                )
              else
                _FoodDetailContent(
                  prediction: activePrediction,
                  onChangePressed: onClearSelection,
                ),
              const SizedBox(height: AppSpacing.lg),
              if (activePrediction != null) ...[
                PrimaryButton(
                  label: 'Save Result',
                  icon: LucideIcons.check,
                  onPressed: onSavePressed,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: onScanAgainPressed,
                  icon: const Icon(LucideIcons.refreshCcw, size: 18),
                  label: const Text('Scan Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PredictionList extends StatelessWidget {
  const _PredictionList({
    required this.predictions,
    required this.onPredictionSelected,
  });

  final List<FoodPrediction> predictions;
  final ValueChanged<FoodPrediction> onPredictionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: predictions.asMap().entries.map((entry) {
        final index = entry.key;
        final prediction = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == predictions.length - 1 ? 0 : AppSpacing.sm,
          ),
          child: _PredictionTile(
            rank: index + 1,
            prediction: prediction,
            onTap: () => onPredictionSelected(prediction),
          ),
        );
      }).toList(),
    );
  }
}

class _PredictionTile extends StatelessWidget {
  const _PredictionTile({
    required this.rank,
    required this.prediction,
    required this.onTap,
  });

  final int rank;
  final FoodPrediction prediction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidencePercent = prediction.confidence.clamp(0.0, 1.0);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: theme.textTheme.labelMedium?.copyWith(
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
                      prediction.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: confidencePercent,
                        minHeight: 7,
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.confidence(prediction.confidence),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodDetailContent extends StatelessWidget {
  const _FoodDetailContent({
    required this.prediction,
    required this.onChangePressed,
  });

  final FoodPrediction prediction;
  final VoidCallback onChangePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nutrition = prediction.nutrition;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${Formatters.calories(nutrition.calories)} estimated',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Confidence ${Formatters.confidence(prediction.confidence)}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _NutritionPill(
                      label: 'Protein',
                      value: Formatters.grams(nutrition.protein),
                      color: AppColors.protein,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _NutritionPill(
                      label: 'Carbs',
                      value: Formatters.grams(nutrition.carbs),
                      color: AppColors.carbs,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _NutritionPill(
                      label: 'Fats',
                      value: Formatters.grams(nutrition.fats),
                      color: AppColors.fats,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _NutritionPill(
                      label: 'Sugar',
                      value: Formatters.grams(nutrition.sugar),
                      color: AppColors.sugar,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onChangePressed,
            icon: const Icon(LucideIcons.listRestart, size: 17),
            label: const Text('Change prediction'),
          ),
        ),
      ],
    );
  }
}

class _NutritionPill extends StatelessWidget {
  const _NutritionPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}