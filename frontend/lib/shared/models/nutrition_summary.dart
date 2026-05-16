class NutritionSummary {
  const NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.sugar,
  });

  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double sugar;

  NutritionSummary copyWith({
    int? calories,
    double? protein,
    double? carbs,
    double? fats,
    double? sugar,
  }) {
    return NutritionSummary(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      sugar: sugar ?? this.sugar,
    );
  }
}