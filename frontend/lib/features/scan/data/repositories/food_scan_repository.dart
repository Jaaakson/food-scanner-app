import 'package:image_picker/image_picker.dart';

import '../../models/food_prediction.dart';
import '../mock/mock_food_predictions.dart';

class FoodScanRepository {
  const FoodScanRepository();

  Future<List<FoodPrediction>> analyzeImage(XFile image) async {
    // Simulates image preprocessing + network request + model inference.
    await Future<void>.delayed(const Duration(milliseconds: 1800));

    return MockFoodPredictions.predictions;
  }
}