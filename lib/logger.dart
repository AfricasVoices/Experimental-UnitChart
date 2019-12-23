import 'dart:html';

class Logger {
  String file;

  Logger(this.file);

  void log(String message) {
    var date = DateTime.now();
    window.console.log("[${this.file} $date] $message");
  }

  void warn(String message) {
    var date = DateTime.now();
    window.console.warn("[${this.file} $date] $message");
  }

  void error(String message) {
    var date = DateTime.now();
    window.console.error("[${this.file} $date] $message");
  }
}
