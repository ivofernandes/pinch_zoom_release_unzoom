import 'package:flutter/material.dart';

class PinchZoomLogger {
  // Singleton
  static final PinchZoomLogger _singleton = PinchZoomLogger._internal();

  factory PinchZoomLogger() => _singleton;

  PinchZoomLogger._internal();

  // Attributes
  bool logFlag = false;

  void log(String message) {
    if (logFlag) {
      debugPrint(message);
    }
  }
}
