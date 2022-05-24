library widgets;

import 'package:flutter/material.dart';

class ResolveSnapshot<T> extends StatelessWidget {
  const ResolveSnapshot({
    Key? key,
    required this.context,
    required this.snapshot,
    this.onError,
    this.loading,
    required this.onData,
  }) : super(key: key);
  final BuildContext context;
  final AsyncSnapshot<T> snapshot;
  final Widget? onError;
  final Widget? loading;
  final Widget Function(T) onData;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasData && snapshot.data != null) {
      return onData.call(snapshot.data as T);
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return loading ?? defaultLoading();
    } else if (snapshot.connectionState == ConnectionState.active ||
        snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return onError ?? viewError(snapshot.error);
      } else if (snapshot.hasData && snapshot.data != null) {
        return onData.call(snapshot.data as T);
      } else {
        return viewError('Empty data');
      }
    } else {
      return viewError(snapshot.connectionState);
    }
  }

  Widget defaultLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget viewError(dynamic error) {
    return Center(child: Text('${error?.toString()}'));
  }
}
