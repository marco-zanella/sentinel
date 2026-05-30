import 'package:flutter/services.dart';
import 'sms_recipient.dart';

class SmsSender {
  static const MethodChannel _channel =
      MethodChannel('io.github.marco_zanella.sentinel/sms');

  static Future<bool> send(SmsRecipient recipient, String message) async {
    try {
      final bool result =
          await _channel.invokeMethod<bool>('sendSms', {
                'phone': recipient.phoneNumber,
                'message': message,
              }) ??
              false;
      return result;
    } catch (_) {
      // Catches both PlatformException and MissingPluginException (the latter
      // if the SMS plugin is not registered in the current Flutter engine).
      return false;
    }
  }
}
