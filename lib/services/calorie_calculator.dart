import '../data/record_repository.dart';

class CalorieCalculator {
  double itemCalorie(double weightGrams, double caloriePerGram) =>
      weightGrams * caloriePerGram;

  double totalCalorie(List<RecordItem> items) =>
      items.fold(0, (sum, item) => sum + item.itemCalorie);

  double round(double value) =>
      double.parse(value.toStringAsFixed(1));
}
