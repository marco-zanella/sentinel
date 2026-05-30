import 'package:flutter/foundation.dart';
import '../models/app_config.dart';
import '../services/config_service.dart';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier(this.config);

  AppConfig config;

  Future<void> save() async {
    await ConfigService.save(config);
    notifyListeners();
  }
}
