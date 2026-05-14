import '../data/record_repository.dart';

class RecordService {
  final RecordRepository _repo;

  RecordService(this._repo);

  Future<Record> createRecord({
    required String imageLocalUri,
    required List<RecordItem> items,
  }) async {
    final id = RecordRepository.generateId();
    final now = DateTime.now().toIso8601String();
    final total = items.fold(0.0, (sum, item) => sum + item.itemCalorie);
    final record = Record(
      id: id,
      createdAt: now,
      imageLocalUri: imageLocalUri,
      totalCalorie: total,
      items: items,
    );
    await _repo.save(record);
    return record;
  }

  Future<List<Record>> getRecordsByDate(String date) => _repo.getByDate(date);

  Future<void> deleteRecord(String id) => _repo.delete(id);
}
