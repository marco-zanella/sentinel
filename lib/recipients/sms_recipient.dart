import 'package:hive/hive.dart';
import '../models/recipient.dart';

part 'sms_recipient.g.dart';

@HiveType(typeId: 0)
class SmsRecipient implements Recipient {
  SmsRecipient({required this.label, required this.phoneNumber});

  @HiveField(0)
  String label;

  @HiveField(1)
  String phoneNumber;

  @override
  String get displayName => label.isNotEmpty ? label : phoneNumber;

  @override
  String get recipientType => 'sms';
}
