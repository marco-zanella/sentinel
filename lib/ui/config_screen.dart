import 'package:flutter/material.dart';
import '../models/delivery_policy.dart';
import '../models/recipient_group.dart';
import 'app_state.dart';
import 'group_edit_screen.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key, required this.appState});

  final AppStateNotifier appState;

  static const List<int> _intervalOptions = [1, 2, 5, 10, 15, 30, 60];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (BuildContext context, Widget? _) {
        final config = appState.config;

        return Scaffold(
          appBar: AppBar(title: const Text('Configuration')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addGroup(context),
            tooltip: 'Add group',
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.smartphone_outlined),
                title: const Text('Device name'),
                subtitle: Text(
                  config.deviceName?.isNotEmpty == true
                      ? config.deviceName!
                      : 'Tap to set',
                ),
                onTap: () => _editDeviceName(context, config),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('Tracking interval'),
                trailing: DropdownButton<int>(
                  value: _intervalOptions.contains(config.intervalMinutes)
                      ? config.intervalMinutes
                      : _intervalOptions[2],
                  underline: const SizedBox.shrink(),
                  items: _intervalOptions
                      .map(
                        (int v) => DropdownMenuItem<int>(
                          value: v,
                          child: Text('$v min'),
                        ),
                      )
                      .toList(),
                  onChanged: (int? value) async {
                    if (value != null) {
                      config.intervalMinutes = value;
                      await appState.save();
                    }
                  },
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: config.groups.isEmpty
                    ? const Center(
                        child: Text(
                          'No recipient groups yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: config.groups.length,
                        onReorderItem: (int oldIndex, int newIndex) async {
                          final RecipientGroup group =
                              config.groups.removeAt(oldIndex);
                          config.groups.insert(newIndex, group);
                          await appState.save();
                        },
                        itemBuilder: (BuildContext context, int index) {
                          final RecipientGroup group = config.groups[index];
                          return _GroupTile(
                            key: ValueKey<int>(index),
                            group: group,
                            index: index,
                            onEdit: () => _editGroup(context, index),
                            onDelete: () async {
                              config.groups.removeAt(index);
                              await appState.save();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editDeviceName(BuildContext context, dynamic config) async {
    final TextEditingController controller = TextEditingController(
      text: config.deviceName ?? '',
    );
    final String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Device name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g. Marco's phone",
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (String v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      config.deviceName = result;
      await appState.save();
    }
  }

  Future<void> _addGroup(BuildContext context) async {
    final RecipientGroup? result = await Navigator.push<RecipientGroup>(
      context,
      MaterialPageRoute<RecipientGroup>(
        builder: (_) => const GroupEditScreen(),
      ),
    );
    if (result != null) {
      appState.config.groups.add(result);
      await appState.save();
    }
  }

  Future<void> _editGroup(BuildContext context, int index) async {
    final RecipientGroup? result = await Navigator.push<RecipientGroup>(
      context,
      MaterialPageRoute<RecipientGroup>(
        builder: (_) =>
            GroupEditScreen(group: appState.config.groups[index]),
      ),
    );
    if (result != null) {
      appState.config.groups[index] = result;
      await appState.save();
    }
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    super.key,
    required this.group,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  final RecipientGroup group;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final int count = group.recipients.length;
    final String policyLabel =
        group.policy == DeliveryPolicy.any ? 'any' : 'all';

    return ListTile(
      onTap: onEdit,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        group.name.isNotEmpty ? group.name : '(unnamed group)',
      ),
      subtitle: Text(
        '$count recipient${count == 1 ? '' : 's'} · $policyLabel policy',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
          const Icon(Icons.drag_handle),
        ],
      ),
    );
  }
}
