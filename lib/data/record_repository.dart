import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'database_helper.dart';

class Record {
  final String id;
  final String createdAt;
  final String imageLocalUri;
  final double totalCalorie;
  final List<RecordItem> items;

  const Record({
    required this.id,
    required this.createdAt,
    required this.imageLocalUri,
    required this.totalCalorie,
    required this.items,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'created_at': createdAt,
        'image_local_uri': imageLocalUri,
        'total_calorie': totalCalorie,
      };
}

class RecordItem {
  final String id;
  final String recordId;
  final String foodName;
  final double confidence;
  final double weightGrams;
  final double caloriePerGram;
  final double itemCalorie;

  const RecordItem({
    required this.id,
    required this.recordId,
    required this.foodName,
    required this.confidence,
    required this.weightGrams,
    required this.caloriePerGram,
    required this.itemCalorie,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'record_id': recordId,
        'food_name': foodName,
        'confidence': confidence,
        'weight_grams': weightGrams,
        'calorie_per_gram': caloriePerGram,
        'item_calorie': itemCalorie,
      };

  factory RecordItem.fromMap(Map<String, dynamic> map) => RecordItem(
        id: map['id'] as String,
        recordId: map['record_id'] as String,
        foodName: map['food_name'] as String,
        confidence: (map['confidence'] as num).toDouble(),
        weightGrams: (map['weight_grams'] as num).toDouble(),
        caloriePerGram: (map['calorie_per_gram'] as num).toDouble(),
        itemCalorie: (map['item_calorie'] as num).toDouble(),
      );

  RecordItem copyWith({double? weightGrams, double? caloriePerGram}) {
    final w = weightGrams ?? this.weightGrams;
    final c = caloriePerGram ?? this.caloriePerGram;
    return RecordItem(
      id: id,
      recordId: recordId,
      foodName: foodName,
      confidence: confidence,
      weightGrams: w,
      caloriePerGram: c,
      itemCalorie: w * c,
    );
  }
}

class RecordRepository {
  static const _uuid = Uuid();

  Future<void> save(Record record) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.insert('records', record.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (final item in record.items) {
        await txn.insert('record_items', item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<Record>> getByDate(String date) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('records',
        where: "date(created_at) = date(?)",
        whereArgs: [date],
        orderBy: 'created_at DESC');
    final records = <Record>[];
    for (final map in maps) {
      final items = await _getItems(db, map['id'] as String);
      records.add(Record(
        id: map['id'] as String,
        createdAt: map['created_at'] as String,
        imageLocalUri: map['image_local_uri'] as String,
        totalCalorie: (map['total_calorie'] as num).toDouble(),
        items: items,
      ));
    }
    return records;
  }

  Future<List<RecordItem>> _getItems(Database db, String recordId) async {
    final maps = await db.query('record_items',
        where: 'record_id = ?', whereArgs: [recordId]);
    return maps.map((m) => RecordItem.fromMap(m)).toList();
  }

  Future<void> delete(String recordId) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete('record_items', where: 'record_id = ?', whereArgs: [recordId]);
      await txn.delete('records', where: 'id = ?', whereArgs: [recordId]);
    });
  }

  static String generateId() => _uuid.v4();
}
