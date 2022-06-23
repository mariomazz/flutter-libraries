import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressCS extends StatelessWidget {
  const ProgressCS({
    Key? key,
    this.color,
    this.center = true,
  }) : super(key: key);

  final Color? color;
  final bool center;

  Color getColor() {
    try {
      if (color != null) {
        return color!;
      }
      return Platform.isIOS || Platform.isMacOS ? Colors.black : Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        if (center) {
          return Center(child: CupertinoActivityIndicator(color: getColor()));
        }
        return CupertinoActivityIndicator(color: getColor());
      }
    } catch (e) {
      if (center) {
        return Center(child: CircularProgressIndicator(color: getColor()));
      }
      return CircularProgressIndicator(color: getColor());
    }
    if (center) {
      return Center(child: CircularProgressIndicator(color: getColor()));
    }
    return CircularProgressIndicator(color: getColor());
  }
}
