import 'package:flutter/material.dart';

extension ChangeNotifierExt on ChangeNotifier {
  void completeAddListener(VoidCallback callback) {
    return addListener(callback);
  }
}
