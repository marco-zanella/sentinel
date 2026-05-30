import 'package:hive/hive.dart';

part 'delivery_log.g.dart';

@HiveType(typeId: 4)
class DeliveryLog extends HiveObject {
  DeliveryLog({
    required this.timestamp,
    required this.success,
    required this.message,
    required this.coords,
  });

  @HiveField(0)
  DateTime timestamp;

  @HiveField(1)
  bool success;

  @HiveField(2)
  String message;

  @HiveField(3)
  String coords;
}
