library api_controller;

import 'package:flutter/material.dart';
import 'package:widgets/widgets.dart';

class ApiControllerW<T> extends StatelessWidget {
  const ApiControllerW({
    Key? key,
    required this.stream,
    required this.onData,
    this.onError,
    this.loading,
  }) : super(key: key);

  final Stream<T> stream;
  final Widget? onError;
  final Widget? loading;
  final Widget Function(T) onData;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        return ResolveSnapshot<T>(
          snapshot: snapshot,
          onData: (data) {
            return onData.call(data);
          },
        );

        /* if (snapshot.hasData) {
          return onData.call(snapshot.data);
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading ?? const Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return onError ??
                Center(child: Text('Error => ${snapshot.error?.toString()}'));
          } else if (snapshot.hasData) {
            return onData.call(snapshot.data);
          } else {
            return const Center(child: Text('Empty data'));
          }
        } else {
          return Center(child: Text('State: ${snapshot.connectionState}'));
        } */
      },
    );
  }
}

class ApiController<T> {
  Future<T> Function() fetchData;

  // BLOC

  ApiController({required this.fetchData});

  T? _dataSaved;

  Stream<T> get stream => streamData();

  Stream<T> streamData() async* {
    if (_dataSaved == null) {
      final data = await fetchData.call();
      _dataSaved = data;
      yield data;
    } else {
      yield _dataSaved!;
    }
  }

  void clear() => {_dataSaved = null};

  // END BLOC

}
