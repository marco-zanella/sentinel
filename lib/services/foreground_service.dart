import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../models/app_config.dart';
import 'config_service.dart';
import 'delivery_service.dart';

// Must be a top-level function — runs in the background isolate.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SentinelTaskHandler());
}

class SentinelTaskHandler extends TaskHandler {
  bool _initialised = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await ConfigService.initialize();
    _initialised = true;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    if (!_initialised) return;
    _updateNotification(timestamp);
    _deliverAndSave(); // fire-and-forget async
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  /// Reloads config from Hive on every event so changes made in the UI
  /// (new recipients, edited groups) take effect without restarting tracking.
  Future<void> _deliverAndSave() async {
    final AppConfig config = await ConfigService.load();
    await DeliveryService.sendNow(config);
    await ConfigService.save(config);
  }

  void _updateNotification(DateTime t) {
    final String time =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    FlutterForegroundTask.updateService(
      notificationTitle: 'Sentinel',
      notificationText: 'Tracking · last ping $time',
      notificationIcon: ForegroundService._notificationIcon,
    );
  }
}

class ForegroundService {
  static const int _serviceId = 256;

  static const NotificationIcon _notificationIcon = NotificationIcon(
    metaDataName: 'io.github.marco_zanella.sentinel.ic_notification',
  );

  static void _init(int intervalMinutes) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sentinel_tracking',
        channelName: 'Sentinel Tracking',
        channelDescription:
            'Shown while Sentinel is actively tracking your location.',
        onlyAlertOnce: true,
        enableVibration: false,
        playSound: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction:
            ForegroundTaskEventAction.repeat(intervalMinutes * 60 * 1000),
        autoRunOnBoot: true,
        allowWakeLock: true,
      ),
    );
  }

  /// Initialise with a safe default so [isRunningService] works before start.
  static void initDefault(int intervalMinutes) => _init(intervalMinutes);

  static Future<ServiceRequestResult> start(int intervalMinutes) {
    _init(intervalMinutes); // always use the latest interval from config
    return FlutterForegroundTask.startService(
      serviceId: _serviceId,
      notificationTitle: 'Sentinel',
      notificationText: 'Tracking active',
      notificationIcon: _notificationIcon,
      callback: startCallback,
    );
  }

  static Future<ServiceRequestResult> stop() =>
      FlutterForegroundTask.stopService();

  static Future<bool> get isRunning => FlutterForegroundTask.isRunningService;
}
