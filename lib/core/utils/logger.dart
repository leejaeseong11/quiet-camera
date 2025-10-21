import 'dart:developer' as developer;

class Logger {
  static void log(String message, {String? tag}) {
    final tagStr = tag != null ? '[$tag] ' : '';
    developer.log('$tagStr$message');
  }
  
  static void info(String message, {String? tag}) {
    log('INFO: $message', tag: tag);
  }
  
  static void warning(String message, {String? tag}) {
    log('WARNING: $message', tag: tag);
  }
  
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    log('ERROR: $message', tag: tag);
    if (error != null) {
      developer.log('Error: $error', error: error, stackTrace: stackTrace);
    }
  }
  
  static void debug(String message, {String? tag}) {
    log('DEBUG: $message', tag: tag);
  }
}
