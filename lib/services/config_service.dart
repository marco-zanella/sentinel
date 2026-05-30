import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_config.dart';
import '../models/delivery_log.dart';
import '../models/recipient_group.dart';
import '../recipients/sms_recipient.dart';
import '../recipients/telegram_recipient.dart';

class ConfigService {
  static const String _boxName = 'sentinel_config';
  static const String _configKey = 'config';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SmsRecipientAdapter());
    Hive.registerAdapter(TelegramRecipientAdapter());
    Hive.registerAdapter(RecipientGroupAdapter());
    Hive.registerAdapter(AppConfigAdapter());
    Hive.registerAdapter(DeliveryLogAdapter());
  }

  static Future<Box<AppConfig>> _openBox() =>
      Hive.openBox<AppConfig>(_boxName);

  static Future<AppConfig> load() async {
    final Box<AppConfig> box = await _openBox();
    return box.get(_configKey) ?? AppConfig();
  }

  static Future<void> save(AppConfig config) async {
    final Box<AppConfig> box = await _openBox();
    await box.put(_configKey, config);
  }
}
