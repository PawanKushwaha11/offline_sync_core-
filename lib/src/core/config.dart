class OfflineSyncConfig {
  final int maxRetries;
  final bool enableLogging;
  final bool backgroundSyncEnabled;
  final Duration defaultTtl;

  const OfflineSyncConfig({
    this.maxRetries = 3,
    this.enableLogging = false,
    this.backgroundSyncEnabled = false,
    this.defaultTtl = const Duration(minutes: 5),
  });
}
