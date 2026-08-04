class OllamaConfigurationException implements Exception {
  final String message;
  OllamaConfigurationException(this.message);

  @override
  String toString() => 'OllamaConfigurationException: $message';
}
