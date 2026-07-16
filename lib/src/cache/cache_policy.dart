/// Caching strategies defining how requests are resolved.
enum CachePolicy {
  /// Serve from cache first; fetch from network only if cache is missing or expired.
  cacheFirst,

  /// Attempt network fetch first; fall back to cache only on network failure.
  networkFirst,

  /// Serve only from local cache. Do not perform network requests.
  cacheOnly,

  /// Perform only network requests. Do not read from cache.
  networkOnly,
}
