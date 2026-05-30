import 'package:flutter/material.dart';
import '../models/delivery_policy.dart';
import '../models/recipient.dart';
import '../models/recipient_group.dart';
import 'recipient_edit_screen.dart';

class GroupEditScreen extends StatefulWidget {
  const GroupEditScreen({super.key, this.group});

  final RecipientGroup? group;

  @override
  State<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  late final TextEditingController _nameController;
  late DeliveryPolicy _policy;
  late List<dynamic> _recipients;

  @override
  void initState() {
    super.initState();
    final RecipientGroup? g = widget.group;
    _nameController = TextEditingController(text: g?.name ?? '');
    _policy = g?.policy ?? DeliveryPolicy.any;
    _recipients = List<dynamic>.from(g?.recipients ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  RecipientGroup _buildResult() => RecipientGroup(
        name: _nameController.text.trim(),
        recipients: _recipients,
        policyValue: _policy.name,
      );

  Future<void> _addRecipient() async {
    final Recipient? result = await Navigator.push<Recipient>(
      context,
      MaterialPageRoute<Recipient>(
        builder: (_) => const RecipientEditScreen(),
      ),
    );
    if (result != null) {
      setState(() => _recipients.add(result));
    }
  }

  Future<void> _editRecipient(int index) async {
    final Recipient? result = await Navigator.push<Recipient>(
      context,
      MaterialPageRoute<Recipient>(
        builder: (_) =>
            RecipientEditScreen(recipient: _recipients[index] as Recipient),
      ),
    );
    if (result != null) {
      setState(() => _recipients[index] = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group == null ? 'New Group' : 'Edit Group'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _buildResult()),
            child: const Text('Save'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecipient,
        tooltip: 'Add recipient',
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery policy',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<DeliveryPolicy>(
                  segments: const [
                    ButtonSegment<DeliveryPolicy>(
                      value: DeliveryPolicy.any,
                      label: Text('Any'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                    ButtonSegment<DeliveryPolicy>(
                      value: DeliveryPolicy.all,
                      label: Text('All'),
                      icon: Icon(Icons.done_all),
                    ),
                  ],
                  selected: {_policy},
                  onSelectionChanged: (Set<DeliveryPolicy> selection) =>
                      setState(() => _policy = selection.first),
                ),
                const SizedBox(height: 4),
                Text(
                  _policy == DeliveryPolicy.any
                      ? 'Sends to all recipients. This group counts as delivered if at least one succeeds.'
                      : 'Sends to all recipients. This group counts as delivered only if every recipient succeeds.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              'Recipients',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: _recipients.isEmpty
                ? const Center(
                    child: Text(
                      'No recipients yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: _recipients.length,
                    onReorderItem: (int oldIndex, int newIndex) {
                      setState(() {
                        final dynamic r = _recipients.removeAt(oldIndex);
                        _recipients.insert(newIndex, r);
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      final Recipient r = _recipients[index] as Recipient;
                      return ListTile(
                        key: ValueKey<int>(index),
                        onTap: () => _editRecipient(index),
                        leading: Icon(
                          r.recipientType == 'sms'
                              ? Icons.sms_outlined
                              : Icons.send_outlined,
                        ),
                        title: Text(r.displayName),
                        subtitle: Text(r.recipientType.toUpperCase()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  setState(() => _recipients.removeAt(index)),
                              tooltip: 'Delete',
                            ),
                            const Icon(Icons.drag_handle),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
