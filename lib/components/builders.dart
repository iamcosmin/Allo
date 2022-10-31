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

class FutureView<T> extends StatelessWidget {
  const FutureView(
    this.future, {
    required this.loading,
    required this.data,
    required this.error,
    super.key,
  });
  final Future<T> future;
  final Widget Function() loading;
  final Widget Function(T value) data;
  final Widget Function(Object? error, StackTrace? stackTrace) error;

  @override
  Widget build(context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return data(snapshot.data as T);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else if (snapshot.hasError) {
          return error(snapshot.error, snapshot.stackTrace);
        } else {
          throw Exception('StreamView could not decide what to render.');
        }
      },
    );
  }
}

class StreamView<T> extends StatelessWidget {
  const StreamView(
    this.stream, {
    required this.loading,
    required this.data,
    required this.error,
    super.key,
  });
  final Stream<T> stream;
  final Widget Function() loading;
  final Widget Function(T value) data;
  final Widget Function(Object? error, StackTrace? stackTrace) error;

  @override
  Widget build(context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return data(snapshot.data as T);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else if (snapshot.hasError) {
          return error(snapshot.error, snapshot.stackTrace);
        } else {
          throw Exception('StreamView could not decide what to render.');
        }
      },
    );
  }
}
