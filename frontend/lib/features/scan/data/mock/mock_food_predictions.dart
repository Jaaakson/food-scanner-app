import '../../../../shared/models/nutrition_summary.dart';
import '../../models/food_prediction.dart';

class MockFoodPredictions {
  const MockFoodPredictions._();

  static const List<FoodPrediction> predictions = [
    FoodPrediction(
      id: 'nasi_goreng',
      name: 'Nasi Goreng',
      confidence: 0.91,
      nutrition: NutritionSummary(
        calories: 640,
        protein: 22,
        carbs: 78,
        fats: 24,
        sugar: 7,
      ),
    ),
    FoodPrediction(
      id: 'mie_goreng',
      name: 'Mie Goreng',
      confidence: 0.74,
      nutrition: NutritionSummary(
        calories: 570,
        protein: 18,
        carbs: 71,
        fats: 21,
        sugar: 8,
      ),
    ),
    FoodPrediction(
      id: 'ayam_geprek',
      name: 'Ayam Geprek',
      confidence: 0.62,
      nutrition: NutritionSummary(
        calories: 690,
        protein: 36,
        carbs: 54,
        fats: 34,
        sugar: 5,
      ),
    ),
  ];
}