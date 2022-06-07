import 'package:flutter/material.dart';
import 'progress.dart';

class PopUpBuilder {
  static bool _loading = false;

  static set _setDialog(bool loading) {
    _loading = loading;
  }

  static void showLoading(BuildContext context,
      {Widget builder = const ProgressCS()}) {
    if (!_loading) {
      showDialog(
          barrierDismissible: false,
          context: context,
          barrierColor: Colors.black.withOpacity(0.1),
          builder: (context) => builder).then(
        (_) => _setDialog = false,
      );
      _setDialog = true;
    }
  }

  static void closeLoading(BuildContext context) {
    if (_loading) {
      Navigator.of(context).pop();
    }
  }
}
