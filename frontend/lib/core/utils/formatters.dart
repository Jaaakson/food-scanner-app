class Formatters {
  const Formatters._();

  static String calories(num value) {
    return '${value.round()} kcal';
  }

  static String grams(num value) {
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} g';
  }

  static String percentage(num value) {
    return '${value.round()}%';
  }
}