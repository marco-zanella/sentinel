import 'package:hive/hive.dart';
import 'delivery_policy.dart';
import 'recipient.dart';

part 'recipient_group.g.dart';

@HiveType(typeId: 2)
class RecipientGroup {
  RecipientGroup({
    required this.name,
    List<dynamic>? recipients,
    this.policyValue = 'any',
  }) : recipients = recipients ?? [];

  @HiveField(0)
  String name;

  // Typed as dynamic so Hive uses each element's registered adapter.
  @HiveField(1)
  List<dynamic> recipients;

  @HiveField(2)
  String policyValue;

  DeliveryPolicy get policy => DeliveryPolicy.values.byName(policyValue);
  set policy(DeliveryPolicy p) => policyValue = p.name;

  List<Recipient> get typedRecipients => recipients.cast<Recipient>();
}
