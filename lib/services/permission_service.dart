import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Permissions needed for a foreground "Send Now": location + SMS.
  static Future<List<String>> requestForSend() =>
      _request(backgroundLocation: false);

  /// Permissions needed for background tracking: location + background
  /// location + SMS.
  static Future<List<String>> requestForTracking() =>
      _request(backgroundLocation: true);

  static Future<List<String>> _request(
      {required bool backgroundLocation}) async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.sms,
    ].request();

    final List<String> denied = [];

    final bool locationGranted =
        statuses[Permission.locationWhenInUse]?.isGranted == true;

    if (!locationGranted) {
      denied.add('Location');
    } else if (backgroundLocation) {
      // Background location must be requested *after* fine location is granted.
      // On Android 11+, this redirects the user to the system settings page
      // where they must select "Allow all the time".
      final PermissionStatus bg = await Permission.locationAlways.request();
      if (!bg.isGranted) {
        denied.add(
          'Background location — open Settings and choose "Allow all the time"',
        );
      }
    }

    if (statuses[Permission.sms]?.isGranted != true) {
      denied.add('SMS');
    }

    return denied;
  }

  static Future<void> openSettings() => openAppSettings();
}
