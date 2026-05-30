import 'package:hive/hive.dart';
import 'recipient_group.dart';

part 'app_config.g.dart';

@HiveType(typeId: 3)
class AppConfig extends HiveObject {
  AppConfig({
    List<RecipientGroup>? groups,
    this.intervalMinutes = 5,
    this.isTracking = false,
    this.deviceName,
    this.lastDeliveryAt,
    this.lastDeliverySuccess,
    this.lastDeliveryMessage,
  }) : groups = groups ?? [];

  @HiveField(0)
  List<RecipientGroup> groups;

  @HiveField(1)
  int intervalMinutes;

  @HiveField(2)
  bool isTracking;

  /// Human-readable device name shown in delivery messages.
  @HiveField(3)
  String? deviceName;

  @HiveField(4)
  DateTime? lastDeliveryAt;

  @HiveField(5)
  bool? lastDeliverySuccess;

  @HiveField(6)
  String? lastDeliveryMessage;
}
