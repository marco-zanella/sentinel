import 'package:hive/hive.dart';
import '../models/recipient.dart';

part 'telegram_recipient.g.dart';

@HiveType(typeId: 1)
class TelegramRecipient implements Recipient {
  TelegramRecipient({
    required this.label,
    required this.botToken,
    required this.chatId,
  });

  @HiveField(0)
  String label;

  @HiveField(1)
  String botToken;

  @HiveField(2)
  String chatId;

  @override
  String get displayName => label.isNotEmpty ? label : chatId;

  @override
  String get recipientType => 'telegram';
}
