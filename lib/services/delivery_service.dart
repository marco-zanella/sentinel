import 'package:geolocator/geolocator.dart';
import '../models/app_config.dart';
import '../models/delivery_log.dart';
import '../models/delivery_policy.dart';
import '../models/recipient.dart';
import '../models/recipient_group.dart';
import '../recipients/sms_recipient.dart';
import '../recipients/sms_sender.dart';
import '../recipients/telegram_recipient.dart';
import '../recipients/telegram_sender.dart';
import 'location_service.dart';
import 'log_service.dart';

class DeliveryResult {
  const DeliveryResult({
    required this.success,
    required this.message,
    this.coords = '',
  });

  final bool success;
  final String message;
  final String coords;
}

class DeliveryService {
  /// Reads GPS, delivers to the first successful recipient group, writes a log
  /// entry, and updates [config]'s last-delivery fields. The caller is
  /// responsible for persisting [config] afterward.
  static Future<DeliveryResult> sendNow(AppConfig config) async {
    if (config.groups.isEmpty) {
      return _finish(
        config,
        result: const DeliveryResult(
          success: false,
          message: 'No recipient groups configured.',
        ),
      );
    }

    final Position position;
    try {
      position = await LocationService.getCurrentPosition();
    } catch (e) {
      return _finish(
        config,
        result: DeliveryResult(
          success: false,
          message: 'Location error: $e',
        ),
      );
    }

    final String coords = LocationService.formatCoordinates(position);
    final String accuracy = LocationService.formatAccuracy(position);
    final String url = LocationService.mapsUrl(position);
    final String name = config.deviceName?.isNotEmpty == true
        ? config.deviceName!
        : 'Sentinel';

    final String smsPayload = '$name: $coords $accuracy $url';
    final String telegramPayload = '📍 $name\n$coords $accuracy\n$url';

    for (final RecipientGroup group in config.groups) {
      if (await _deliverToGroup(group, smsPayload, telegramPayload)) {
        return _finish(
          config,
          result: DeliveryResult(
            success: true,
            message: 'Sent via "${group.name.isNotEmpty ? group.name : 'group'}"',
            coords: coords,
          ),
        );
      }
    }

    return _finish(
      config,
      result: DeliveryResult(
        success: false,
        message: 'All delivery groups failed.',
        coords: coords,
      ),
    );
  }

  static Future<DeliveryResult> _finish(
    AppConfig config, {
    required DeliveryResult result,
  }) async {
    config.lastDeliveryAt = DateTime.now();
    config.lastDeliverySuccess = result.success;
    config.lastDeliveryMessage = result.message;

    await LogService.append(DeliveryLog(
      timestamp: config.lastDeliveryAt!,
      success: result.success,
      message: result.message,
      coords: result.coords,
    ));

    return result;
  }

  static Future<bool> _deliverToGroup(
    RecipientGroup group,
    String smsPayload,
    String telegramPayload,
  ) async {
    final List<Recipient> recipients = group.typedRecipients;
    if (recipients.isEmpty) return false;

    // Always attempt every recipient regardless of policy.
    // Policy only determines the success condition used for group fallback.
    int successes = 0;
    for (final Recipient r in recipients) {
      if (await _deliverToRecipient(r, smsPayload, telegramPayload)) {
        successes++;
      }
    }

    return group.policy == DeliveryPolicy.any
        ? successes > 0
        : successes == recipients.length;
  }

  static Future<bool> _deliverToRecipient(
    Recipient recipient,
    String smsPayload,
    String telegramPayload,
  ) async {
    if (recipient is SmsRecipient) {
      return SmsSender.send(recipient, smsPayload);
    }
    if (recipient is TelegramRecipient) {
      return TelegramSender.send(recipient, telegramPayload);
    }
    return false;
  }
}
