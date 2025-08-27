import 'package:logger/logger.dart';

/// Centralized logging service for the application
/// 
/// This service provides different log levels:
/// - Debug: For development debugging
/// - Info: For general information 
/// - Warning: For potential issues
/// - Error: For errors and exceptions
/// - Verbose: For detailed tracing
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Should each log print contain a timestamp
    ),
  );

  /// Log debug messages
  /// Use for debugging information during development
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log informational messages
  /// Use for general information about application flow
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning messages
  /// Use for potential issues that don't break functionality
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error messages
  /// Use for errors and exceptions
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log verbose messages
  /// Use for detailed tracing and extensive debugging
  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Log API requests and responses
  /// Specialized method for API-related logging
  static void api(String endpoint, String method, {
    Map<String, dynamic>? requestData,
    dynamic response,
    int? statusCode,
    dynamic error,
  }) {
    final message = '🌐 API $method $endpoint';
    final details = {
      if (statusCode != null) 'status': statusCode,
      if (requestData != null) 'request': requestData,
      if (response != null) 'response': response,
      if (error != null) 'error': error,
    };
    
    if (error != null) {
      _logger.e('$message - Error', error: details);
    } else if (statusCode != null && statusCode >= 400) {
      _logger.w('$message - Warning', error: details);
    } else {
      _logger.d('$message - Success', error: details);
    }
  }

  /// Log authentication events
  /// Specialized method for auth-related logging
  static void auth(String event, {dynamic data, dynamic error}) {
    final message = '🔐 Auth: $event';
    if (error != null) {
      _logger.e(message, error: {'data': data, 'error': error});
    } else {
      _logger.i(message, error: data != null ? {'data': data} : null);
    }
  }

  /// Log quiz-related events
  /// Specialized method for quiz functionality
  static void quiz(String event, {dynamic data, dynamic error}) {
    final message = '🧠 Quiz: $event';
    if (error != null) {
      _logger.e(message, error: {'data': data, 'error': error});
    } else {
      _logger.d(message, error: data != null ? {'data': data} : null);
    }
  }

  /// Log navigation events
  /// Specialized method for navigation tracking
  static void navigation(String route, {String? action, dynamic data}) {
    final message = '🧭 Navigation: ${action ?? 'navigate'} to $route';
    _logger.d(message, error: data != null ? {'data': data} : null);
  }
}
