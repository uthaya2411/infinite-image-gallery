class EnvConfig {
  static const String _envApiKey = String.fromEnvironment('PIXABAY_API_KEY');
  static String? _runtimeApiKey;

  static void setRuntimeApiKey(String key) {
    _runtimeApiKey = key.trim().isEmpty ? null : key.trim();
  }

  static String get apiKey {
    if (_runtimeApiKey != null && _runtimeApiKey!.isNotEmpty) {
      return _runtimeApiKey!;
    }
    return _envApiKey;
  }

  static bool get hasApiKey => apiKey.isNotEmpty;
}
