import 'package:flutter/material.dart';

class ShowLoading extends StatelessWidget {
  const ShowLoading({
    Key? key,
    required this.controller,
    required this.builder,
    this.progress = const CircularProgressIndicator(),
  }) : super(key: key);
  final LoadingController controller;
  final Widget builder;
  final Widget progress;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.showLoading,
      builder: (context, data, _) {
        if (data) {
          return Stack(
            children: [
              builder,
              _loading(),
            ],
          );
        }

        return builder;
      },
    );
  }

  Widget _loading() {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
        ),
        child: Center(
          child: progress,
        ),
      ),
    );
  }
}

class LoadingController {
  final ValueNotifier<bool> _showLoading = ValueNotifier<bool>(false);

  ValueNotifier<bool> get showLoading => _showLoading;

  void show() {
    _showLoading.value = true;
  }

  void close() {
    _showLoading.value = false;
  }

  void dispose() {
    _showLoading.dispose();
  }
}
