import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'models/app_config.dart';
import 'services/config_service.dart';
import 'services/foreground_service.dart';
import 'ui/app_state.dart';
import 'ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.initialize();
  final AppConfig config = await ConfigService.load();

  bool needsSave = false;

  // Populate device name once on first launch.
  if (config.deviceName == null || config.deviceName!.isEmpty) {
    try {
      final AndroidDeviceInfo info =
          await DeviceInfoPlugin().androidInfo;
      config.deviceName =
          '${_capitalize(info.brand)} ${info.model}';
    } catch (_) {
      config.deviceName = 'Sentinel';
    }
    needsSave = true;
  }

  ForegroundService.initDefault(config.intervalMinutes);

  // Sync the stored flag with the actual service state so the UI is correct
  // if the service was killed or stopped outside the app.
  final bool actuallyRunning = await ForegroundService.isRunning;
  if (config.isTracking != actuallyRunning) {
    config.isTracking = actuallyRunning;
    needsSave = true;
  }

  if (needsSave) await ConfigService.save(config);

  runApp(SentinelApp(appState: AppStateNotifier(config)));
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

class SentinelApp extends StatelessWidget {
  const SentinelApp({super.key, required this.appState});

  final AppStateNotifier appState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentinel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: HomeScreen(appState: appState),
    );
  }
}
