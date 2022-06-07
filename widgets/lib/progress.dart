import 'package:flutter/material.dart';

class ProgressCS extends StatelessWidget {
  const ProgressCS({
    Key? key,
    this.color = Colors.blue,
  }) : super(key: key);
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color,
      ),
    );
  }
}
