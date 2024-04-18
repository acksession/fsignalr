import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ReportingSystem {
  /// Logs the given event into the error reporting system.
  static Future<void> recordEvent({
    required String message,
    ReportingSystemEventLevel? level,
    StackTrace? stackTrace,
    Map<String, String>? tags,
    bool appendDateTime = true,
    bool printToConsole = true,
  }) async {
    final StringBuffer sb = StringBuffer();
    sb.write(message);
    if (appendDateTime) {
      sb.write(
        '[Event recorded at ${DateTime.now().toIso8601String()} by fsignalr library]',
      );
    }
    final String result = sb.toString();

    if (printToConsole && kDebugMode) {
      debugPrint(result);
    }
    await Sentry.captureEvent(
      SentryEvent(
        message: SentryMessage(result),
        tags: tags,
        level: _mapToSentryLevel(level),
      ),
      stackTrace: stackTrace,
    );
  }

  /// Records the given error into error reporting system.
  static Future<void> recordError({
    required dynamic error,
    StackTrace? stackTrace,
  }) async =>
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );

  static SentryLevel _mapToSentryLevel(ReportingSystemEventLevel? level) =>
      switch (level) {
        ReportingSystemEventLevel.debug => SentryLevel.debug,
        ReportingSystemEventLevel.info => SentryLevel.info,
        ReportingSystemEventLevel.error => SentryLevel.error,
        _ => SentryLevel.info
      };
}

/// The level of an event that will be recorded by the [GlobalReportingHandler]
enum ReportingSystemEventLevel {
  debug,
  info,
  error;
}
