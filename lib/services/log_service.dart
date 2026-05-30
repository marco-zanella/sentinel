import 'package:hive/hive.dart';
import '../models/delivery_log.dart';

class LogService {
  static const String _boxName = 'sentinel_log';
  static const int _maxEntries = 100;

  static Future<Box<DeliveryLog>> _openBox() =>
      Hive.openBox<DeliveryLog>(_boxName);

  static Future<void> append(DeliveryLog entry) async {
    final Box<DeliveryLog> box = await _openBox();
    await box.add(entry);
    while (box.length > _maxEntries) {
      await box.deleteAt(0);
    }
  }

  /// Returns entries newest-first.
  static Future<List<DeliveryLog>> load() async {
    final Box<DeliveryLog> box = await _openBox();
    return box.values.toList().reversed.toList();
  }

  static Future<void> clear() async {
    final Box<DeliveryLog> box = await _openBox();
    await box.clear();
  }
}
