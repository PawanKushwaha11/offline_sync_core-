/// A wrapper class representing an item stored in the cache.
///
/// It encapsulates the cached [data] along with metadata like [createdAt]
/// and [expiresAt] to determine TTL validity.
class CacheEntry {
  /// The actual cached content (e.g., Map, List, or primitive types).
  final dynamic data;

  /// The timestamp when this entry was created or fetched.
  final DateTime createdAt;

  /// The timestamp when this entry expires.
  final DateTime expiresAt;

  /// Constructs a [CacheEntry] with required data and timestamps.
  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.expiresAt,
  });

  /// Returns `true` if the current time is after the expiration time ([expiresAt]).
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Converts this [CacheEntry] instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// Restores a [CacheEntry] instance from a serialized JSON Map.
  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
