import 'package:flutter_test/flutter_test.dart';
import 'package:sentinel/models/delivery_policy.dart';
import 'package:sentinel/models/recipient_group.dart';
import 'package:sentinel/recipients/sms_recipient.dart';
import 'package:sentinel/recipients/telegram_recipient.dart';

void main() {
  group('RecipientGroup', () {
    test('default policy is any', () {
      final RecipientGroup group = RecipientGroup(name: 'test');
      expect(group.policy, DeliveryPolicy.any);
    });

    test('policy round-trips through policyValue', () {
      final RecipientGroup group = RecipientGroup(name: 'test');
      group.policy = DeliveryPolicy.all;
      expect(group.policy, DeliveryPolicy.all);
    });

    test('typedRecipients casts correctly', () {
      final SmsRecipient sms =
          SmsRecipient(label: 'Alice', phoneNumber: '+1234567890');
      final TelegramRecipient tg = TelegramRecipient(
        label: 'Bot',
        botToken: 'tok',
        chatId: '42',
      );
      final RecipientGroup group =
          RecipientGroup(name: 'test', recipients: [sms, tg]);

      expect(group.typedRecipients.length, 2);
      expect(group.typedRecipients[0].displayName, 'Alice');
      expect(group.typedRecipients[1].displayName, 'Bot');
    });
  });

  group('SmsRecipient', () {
    test('displayName falls back to phoneNumber when label is empty', () {
      final SmsRecipient r =
          SmsRecipient(label: '', phoneNumber: '+1234567890');
      expect(r.displayName, '+1234567890');
    });

    test('recipientType is sms', () {
      expect(
        SmsRecipient(label: 'x', phoneNumber: '0').recipientType,
        'sms',
      );
    });
  });

  group('TelegramRecipient', () {
    test('displayName falls back to chatId when label is empty', () {
      final TelegramRecipient r =
          TelegramRecipient(label: '', botToken: 'tok', chatId: '99');
      expect(r.displayName, '99');
    });

    test('recipientType is telegram', () {
      expect(
        TelegramRecipient(label: 'x', botToken: 't', chatId: '1').recipientType,
        'telegram',
      );
    });
  });
}
