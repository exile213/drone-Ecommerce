import 'dart:io';
import 'dart:convert';

class DebugLogger {
  static const String logPath = r'c:\Users\ASUS\Desktop\Programming\flutter_projects\ecommercephp\.cursor\debug.log';
  
  static Future<void> log({
    required String location,
    required String message,
    Map<String, dynamic>? data,
    String sessionId = 'debug-session',
    String runId = 'run1',
    String? hypothesisId,
  }) async {
    try {
      final logEntry = {
        'location': location,
        'message': message,
        'data': data ?? {},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sessionId': sessionId,
        'runId': runId,
        if (hypothesisId != null) 'hypothesisId': hypothesisId,
      };
      
      final file = File(logPath);
      final sink = file.openWrite(mode: FileMode.append);
      sink.writeln(jsonEncode(logEntry));
      await sink.close();
    } catch (e) {
      // Silently fail if logging doesn't work
    }
  }
}

