import 'package:flutter/material.dart';

class FutureWidget<T> extends StatelessWidget {
  const FutureWidget({
    required this.future,
    required this.loading,
    required this.success,
    required this.error,
    super.key,
  });

  final Future<T> future;
  final Widget Function(T value) success;
  final Widget Function(Object? errror) error;
  final Widget Function() loading;

  @override
  Widget build(context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return success(snapshot.data as T);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else if (snapshot.hasError) {
          return error(snapshot.error);
        } else {
          throw Exception('An unknown error has occured.');
        }
      },
    );
  }
}
