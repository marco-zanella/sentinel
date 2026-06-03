import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the current position.
  ///
  /// Throws if location services are off or permission is not granted.
  /// Does NOT request permission — call [requestPermission] from the UI first.
  static Future<Position> getCurrentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission not granted. Open Settings and allow location access.',
      );
    }

    // geolocator's timeLimit is unreliable on Android — wrap with a Dart
    // timeout so the button never spins forever if GPS can't get a fix.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    ).timeout(
      const Duration(seconds: 35),
      onTimeout: () => throw TimeoutException('Could not get a GPS fix within 30 s'),
    );
  }

  /// Requests location permission. Call this from the UI before starting
  /// tracking (requires an active Activity context).
  static Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static String formatCoordinates(Position p) =>
      '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}';

  static String formatAccuracy(Position p) => '±${p.accuracy.round()}m';

  static String mapsUrl(Position p) =>
      'https://maps.google.com/?q=${formatCoordinates(p)}';
}
