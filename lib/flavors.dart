/// True in the full (sideloaded) build; false in the Play Store build.
/// Set via --dart-define=SMS_ENABLED=true/false at build time.
const bool kSmsEnabled = bool.fromEnvironment('SMS_ENABLED', defaultValue: true);
