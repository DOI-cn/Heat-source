import '../data/database_helper.dart';

class NutritionCache {
  Future<double?> getCaloriePerGram(String foodName) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('food_nutrition',
        where: 'food_name = ?', whereArgs: [foodName]);
    if (maps.isNotEmpty) {
      return (maps.first['calorie_per_gram'] as num).toDouble();
    }
    return null;
  }

  Future<void> cache(String foodName, double caloriePerGram, String source) async {
    final db = await DatabaseHelper.instance.database;
    try {
      await db.insert(
        'food_nutrition',
        {
          'food_name': foodName,
          'calorie_per_gram': caloriePerGram,
          'source': source,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: null,
      );
    } catch (_) {
      await db.update(
        'food_nutrition',
        {
          'calorie_per_gram': caloriePerGram,
          'source': source,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'food_name = ?',
        whereArgs: [foodName],
      );
    }
  }
}
