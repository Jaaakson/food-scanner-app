import '../../../shared/models/nutrition_summary.dart';

class FoodPrediction {
  const FoodPrediction({
    required this.id,
    required this.name,
    required this.confidence,
    required this.nutrition,
  });

  final String id;
  final String name;

  /// Confidence value in range 0.0 - 1.0.
  final double confidence;

  final NutritionSummary nutrition;
}