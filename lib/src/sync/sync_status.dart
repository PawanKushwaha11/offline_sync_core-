/// The synchronization status of a sync task.
enum SyncStatus {
  /// The task is pending execution.
  pending,

  /// The task is currently syncing with the remote server.
  syncing,

  /// The task synced successfully.
  success,

  /// The task failed to sync after retries.
  failed,
}
