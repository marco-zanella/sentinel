import 'dart:convert';
import 'package:http/http.dart' as http;
import 'telegram_recipient.dart';

class TelegramSender {
  static Future<bool> send(TelegramRecipient recipient, String message) async {
    try {
      final Uri url = Uri.parse(
        'https://api.telegram.org/bot${recipient.botToken}/sendMessage',
      );
      final http.Response response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({
              'chat_id': recipient.chatId,
              'text': message,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        return body['ok'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
