import 'package:flutter/material.dart';

class ShowLoading extends StatelessWidget {
  const ShowLoading({
    Key? key,
    required this.controller,
    required this.builder,
    this.progress = const CircularProgressIndicator(),
    this.background = _color,
    this.opacity = 0.2,
    this.expandContent = true,
  }) : super(key: key);
  final LoadingController controller;
  final Widget builder;
  final Widget progress;
  final Color background;
  final double opacity;
  final bool expandContent;
  static const _color = Color(0xFFFFFFFF);
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
    final loading = Container(
      decoration: BoxDecoration(
        color: background.withOpacity(opacity),
      ),
      child: Center(
        child: progress,
      ),
    );

    return expandContent ? SizedBox.expand(child: loading) : loading;
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
