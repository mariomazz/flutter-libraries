import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressCS extends StatelessWidget {
  const ProgressCS({
    Key? key,
    this.color = Colors.blue,
    this.center = true,
  }) : super(key: key);

  final Color color;
  final bool center;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Platform.isMacOS) {
      if (center) {
        return Center(child: CupertinoActivityIndicator(color: color));
      }
      return CupertinoActivityIndicator(color: color);
    } else {
      if (center) {
        return Center(child: CircularProgressIndicator(color: color));
      }
      return CircularProgressIndicator(color: color);
    }
  }
}
