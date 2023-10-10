import 'package:flutter/material.dart';

class PencilKitMode {
  static const String pen = "pen";
  // static const String marker = "marker";
  static const String eraser = "eraser";
  // static const String fingerDraw = "finger-draw";
  static const String move = "move"; // drag
}

class PencilKitState with ChangeNotifier {
  String _drawMode = PencilKitMode.pen;
  String get drawMode => _drawMode;

  // debug
  bool _regardFingerAsStylus = false;
  bool get regardFingerAsStylus => _regardFingerAsStylus;
  void setRegardFingerAsStylus(bool value) {
    _regardFingerAsStylus = value;
    notifyListeners();
  }

  void setDrawMode(String mode) {
    _drawMode = mode;
    notifyListeners();
  }
}
