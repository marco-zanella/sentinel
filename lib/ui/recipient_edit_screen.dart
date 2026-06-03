import 'package:flutter/material.dart';
import '../flavors.dart';
import '../models/recipient.dart';
import '../recipients/sms_recipient.dart';
import '../recipients/telegram_recipient.dart';

enum _RecipientType { sms, telegram }

class RecipientEditScreen extends StatefulWidget {
  const RecipientEditScreen({super.key, this.recipient});

  final Recipient? recipient;

  @override
  State<RecipientEditScreen> createState() => _RecipientEditScreenState();
}

class _RecipientEditScreenState extends State<RecipientEditScreen> {
  late _RecipientType _type;
  late final TextEditingController _labelController;
  late final TextEditingController _phoneController;
  late final TextEditingController _botTokenController;
  late final TextEditingController _chatIdController;

  @override
  void initState() {
    super.initState();
    final Recipient? r = widget.recipient;

    if (r is SmsRecipient) {
      _type = _RecipientType.sms;
      _labelController = TextEditingController(text: r.label);
      _phoneController = TextEditingController(text: r.phoneNumber);
      _botTokenController = TextEditingController();
      _chatIdController = TextEditingController();
    } else if (r is TelegramRecipient) {
      _type = _RecipientType.telegram;
      _labelController = TextEditingController(text: r.label);
      _phoneController = TextEditingController();
      _botTokenController = TextEditingController(text: r.botToken);
      _chatIdController = TextEditingController(text: r.chatId);
    } else {
      _type = kSmsEnabled ? _RecipientType.sms : _RecipientType.telegram;
      _labelController = TextEditingController();
      _phoneController = TextEditingController();
      _botTokenController = TextEditingController();
      _chatIdController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _phoneController.dispose();
    _botTokenController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  Recipient? _buildResult() {
    final String label = _labelController.text.trim();
    if (_type == _RecipientType.sms) {
      final String phone = _phoneController.text.trim();
      if (phone.isEmpty) return null;
      return SmsRecipient(label: label, phoneNumber: phone);
    } else {
      final String token = _botTokenController.text.trim();
      final String chatId = _chatIdController.text.trim();
      if (token.isEmpty || chatId.isEmpty) return null;
      return TelegramRecipient(label: label, botToken: token, chatId: chatId);
    }
  }

  void _save() {
    final Recipient? result = _buildResult();
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.recipient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recipient' : 'New Recipient'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!isEditing && kSmsEnabled) ...[
            SegmentedButton<_RecipientType>(
              segments: const [
                ButtonSegment<_RecipientType>(
                  value: _RecipientType.sms,
                  label: Text('SMS'),
                  icon: Icon(Icons.sms_outlined),
                ),
                ButtonSegment<_RecipientType>(
                  value: _RecipientType.telegram,
                  label: Text('Telegram'),
                  icon: Icon(Icons.send_outlined),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (Set<_RecipientType> s) =>
                  setState(() => _type = s.first),
            ),
            const SizedBox(height: 24),
          ],
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Label (optional)',
              border: OutlineInputBorder(),
              helperText: 'A friendly name shown in the app',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          if (_type == _RecipientType.sms) ...[
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone number *',
                border: OutlineInputBorder(),
                hintText: '+39 123 456 7890',
                helperText: 'Include country code (e.g. +39 for Italy)',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
          if (_type == _RecipientType.telegram) ...[
            TextField(
              controller: _botTokenController,
              decoration: const InputDecoration(
                labelText: 'Bot token *',
                border: OutlineInputBorder(),
                hintText: '123456789:AABBcc...',
                helperText: 'Create a bot and get the token via @BotFather',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _chatIdController,
              decoration: const InputDecoration(
                labelText: 'Chat ID *',
                border: OutlineInputBorder(),
                hintText: '-1001234567890',
                helperText:
                    'Numeric ID of the chat, group, or channel to notify',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(signed: true),
            ),
          ],
        ],
      ),
    );
  }
}
