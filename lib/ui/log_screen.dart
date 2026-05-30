import 'package:flutter/material.dart';
import '../models/delivery_log.dart';
import '../services/log_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<DeliveryLog> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<DeliveryLog> entries = await LogService.load();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _clear() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Clear log?'),
        content: const Text('All delivery history will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await LogService.clear();
      if (mounted) setState(() => _entries = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Log'),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear log',
              onPressed: _clear,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('No delivery attempts yet.'))
              : ListView.separated(
                  itemCount: _entries.length,
                  separatorBuilder: (BuildContext c, int i) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext ctx, int index) =>
                      _LogTile(entry: _entries[index]),
                ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final DeliveryLog entry;

  @override
  Widget build(BuildContext context) {
    final bool ok = entry.success;
    final Color color = ok
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    final DateTime t = entry.timestamp;
    final String dateTime =
        '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}'
        '  ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return ListTile(
      leading: Icon(
        ok ? Icons.check_circle_outline : Icons.error_outline,
        color: color,
      ),
      title: Text(entry.message),
      subtitle: Text(
        entry.coords.isNotEmpty
            ? '${entry.coords}  ·  $dateTime'
            : dateTime,
      ),
      dense: true,
    );
  }
}
