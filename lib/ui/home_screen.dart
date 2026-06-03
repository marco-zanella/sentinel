import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../services/delivery_service.dart';
import '../services/foreground_service.dart';
import '../services/permission_service.dart';
import 'app_state.dart';
import 'config_screen.dart';
import 'log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.appState});

  final AppStateNotifier appState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isTogglingService = false;
  bool _isSending = false;

  Future<void> _toggleTracking() async {
    setState(() => _isTogglingService = true);
    try {
      if (widget.appState.config.isTracking) {
        final ServiceRequestResult result = await ForegroundService.stop();
        if (result is ServiceRequestSuccess) {
          widget.appState.config.isTracking = false;
          await widget.appState.save();
        } else if (result is ServiceRequestFailure) {
          _showError(result.error);
        }
      } else {
        await FlutterForegroundTask.requestNotificationPermission();
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();

        // Google Play policy requires a prominent in-app disclosure before
        // requesting ACCESS_BACKGROUND_LOCATION. Show it only when the
        // permission has not been granted yet.
        final bool bgAlreadyGranted =
            await PermissionService.isBackgroundLocationGranted;
        if (!bgAlreadyGranted) {
          final bool confirmed = await _showBackgroundLocationDisclosure();
          if (!confirmed) return;
        }

        final List<String> denied =
            await PermissionService.requestForTracking();
        if (denied.isNotEmpty) {
          _showPermissionDenied(denied);
          return;
        }

        final int interval = widget.appState.config.intervalMinutes;
        final ServiceRequestResult result =
            await ForegroundService.start(interval);
        if (result is ServiceRequestSuccess) {
          widget.appState.config.isTracking = true;
          await widget.appState.save();
        } else if (result is ServiceRequestFailure) {
          _showError(result.error);
        }
      }
    } finally {
      if (mounted) setState(() => _isTogglingService = false);
    }
  }

  /// Shows the mandatory prominent disclosure required by Google Play before
  /// requesting background location. Returns true if the user confirmed.
  Future<bool> _showBackgroundLocationDisclosure() async {
    if (!mounted) return false;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Background location access'),
        content: const SingleChildScrollView(
          child: Text(
            'Sentinel collects your device\'s precise GPS location '
            'continuously in the background, including when the app is '
            'closed or not in use.\n\n'
            'This location data is sent directly from your device to your '
            'configured recipients (via Telegram or SMS). It is never '
            'stored on external servers or shared with third parties.\n\n'
            'To enable tracking, you will be asked to grant '
            '"Allow all the time" location access in the next screen.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _sendNow() async {
    setState(() => _isSending = true);
    try {
      final List<String> denied = await PermissionService.requestForSend();
      if (denied.isNotEmpty) {
        _showPermissionDenied(denied);
        return;
      }

      final DeliveryResult result =
          await DeliveryService.sendNow(widget.appState.config);
      await widget.appState.save();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }

  void _showPermissionDenied(List<String> denied) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Missing permissions: ${denied.join(', ')}'),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: PermissionService.openSettings,
        ),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (BuildContext context, Widget? _) {
        final config = widget.appState.config;
        final bool isTracking = config.isTracking;
        final int groupCount = config.groups.length;
        final int recipientCount = config.groups
            .fold(0, (int sum, g) => sum + g.recipients.length);
        final int intervalMinutes = config.intervalMinutes;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sentinel'),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Delivery log',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const LogScreen(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Configuration',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ConfigScreen(appState: widget.appState),
                  ),
                ),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _isTogglingService ? null : _toggleTracking,
                  style: isTracking
                      ? FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                        )
                      : null,
                  icon: _isTogglingService
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Icon(isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(
                      isTracking ? 'Stop Tracking' : 'Start Tracking'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isSending ? null : _sendNow,
                  icon: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Send Now'),
                ),
                const SizedBox(height: 24),
                Text(
                  groupCount == 0
                      ? 'No recipients configured yet.'
                      : '$groupCount group${groupCount == 1 ? '' : 's'} · '
                          '$recipientCount recipient${recipientCount == 1 ? '' : 's'} · '
                          'every $intervalMinutes min',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (groupCount == 0) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ConfigScreen(appState: widget.appState),
                      ),
                    ),
                    icon: const Icon(Icons.settings),
                    label: const Text('Open Configuration'),
                  ),
                ],
                if (config.lastDeliveryAt != null) ...[
                  const SizedBox(height: 16),
                  _LastDeliveryBadge(config: config),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LastDeliveryBadge extends StatelessWidget {
  const _LastDeliveryBadge({required this.config});

  final dynamic config;

  @override
  Widget build(BuildContext context) {
    final bool ok = config.lastDeliverySuccess == true;
    final DateTime t = config.lastDeliveryAt as DateTime;
    final String time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final String label = config.lastDeliveryMessage as String? ?? '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ok ? Icons.check_circle_outline : Icons.error_outline,
          size: 16,
          color: ok
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 6),
        Text(
          '$time · $label',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
