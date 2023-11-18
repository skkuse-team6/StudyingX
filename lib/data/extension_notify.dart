import 'package:flutter/material.dart';

extension ChangeNotifierExtensions on ChangeNotifier {
  void notifyListenersPlease() {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    notifyListeners();
  }
}
