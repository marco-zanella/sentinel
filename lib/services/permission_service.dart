import 'package:permission_handler/permission_handler.dart';
import '../flavors.dart';

class PermissionService {
  /// Permissions needed for a foreground "Send Now".
  static Future<List<String>> requestForSend() =>
      _request(backgroundLocation: false);

  /// Permissions needed for background tracking.
  /// Call this AFTER showing the prominent disclosure required by Google Play
  /// policy (in-app disclosure must precede the background-location dialog).
  static Future<List<String>> requestForTracking() =>
      _request(backgroundLocation: true);

  /// True when background location is already granted, so the UI can
  /// skip the disclosure dialog on subsequent "Start Tracking" taps.
  static Future<bool> get isBackgroundLocationGranted async =>
      (await Permission.locationAlways.status).isGranted;

  static Future<List<String>> _request(
      {required bool backgroundLocation}) async {
    final List<Permission> toRequest = [Permission.locationWhenInUse];
    if (kSmsEnabled) toRequest.add(Permission.sms);

    final Map<Permission, PermissionStatus> statuses =
        await toRequest.request();

    final List<String> denied = [];

    final bool locationGranted =
        statuses[Permission.locationWhenInUse]?.isGranted == true;

    if (!locationGranted) {
      denied.add('Location');
      return denied;
    }

    if (backgroundLocation) {
      // Background location must be requested *after* fine location is granted.
      // On Android 11+, this redirects the user to system settings where they
      // must select "Allow all the time".
      final PermissionStatus bg = await Permission.locationAlways.request();
      if (!bg.isGranted) {
        denied.add(
          'Background location — open Settings and choose "Allow all the time"',
        );
      }
    }

    if (kSmsEnabled && statuses[Permission.sms]?.isGranted != true) {
      denied.add('SMS');
    }

    return denied;
  }

  static Future<void> openSettings() => openAppSettings();
}
