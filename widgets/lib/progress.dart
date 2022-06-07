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
    if (center) {
      return Center(child: CircularProgressIndicator(color: color));
    }
    return CircularProgressIndicator(color: color);
  }
}
