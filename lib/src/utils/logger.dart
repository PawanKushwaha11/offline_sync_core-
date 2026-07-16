import 'package:logger/logger.dart';

class SyncLogger {
  static SyncLogger? _instance;
  late final Logger _logger;
  final bool _enabled;

  SyncLogger._({bool enabled = false}) : _enabled = enabled {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: true,
        printEmojis: true,
      ),
    );
  }

  static SyncLogger get instance => _instance ??= SyncLogger._();

  static void configure({bool enabled = false}) {
    _instance = SyncLogger._(enabled: enabled);
  }

  void info(String message) {
    if (_enabled) _logger.i(message);
  }

  void warning(String message) {
    if (_enabled) _logger.w(message);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enabled) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void debug(String message) {
    if (_enabled) _logger.d(message);
  }
}
