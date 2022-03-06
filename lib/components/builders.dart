import 'package:allo/logic/client/extensions.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef AsyncSuccessData<T> = Widget Function(BuildContext context, T data);
typedef AsyncErrorData = Widget? Function(BuildContext context, Object? error)?;

class StreamView<T> extends HookConsumerWidget {
  const StreamView(
      {required this.stream,
      required this.success,
      this.failed,
      this.error,
      this.loading,
      Key? key})
      : super(key: key);
  final Stream<T> stream;
  final AsyncSuccessData success;
  final Widget? loading;
  final AsyncErrorData error;
  final Widget? failed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        return _switcher<T>(context, snapshot, success, error, loading, failed);
      },
    );
  }
}

class FutureView<T> extends HookConsumerWidget {
  const FutureView(
      {required this.future,
      required this.success,
      this.failed,
      this.error,
      this.loading,
      Key? key})
      : super(key: key);
  final Future<T> future;
  final AsyncSuccessData<T> success;
  final Widget? loading;
  final AsyncErrorData error;
  final Widget? failed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        return _switcher<T>(context, snapshot, success, error, loading, failed);
      },
    );
  }
}

PageTransitionSwitcher _switcher<T>(
  BuildContext context,
  AsyncSnapshot snapshot,
  AsyncSuccessData<T> success,
  AsyncErrorData error,
  Widget? loading,
  Widget? failed,
) {
  return PageTransitionSwitcher(
    duration: const Duration(milliseconds: 300),
    transitionBuilder: (child, animation, secondaryAnimation) {
      return SharedAxisTransition(
        fillColor: Theme.of(context).colorScheme.surface,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.vertical,
        child: child,
      );
    },
    child: _child<T>(snapshot, context, success, error, loading, failed),
  );
}

Widget _child<T>(
  AsyncSnapshot snapshot,
  BuildContext context,
  AsyncSuccessData<T> success,
  AsyncErrorData error,
  Widget? loading,
  Widget? failed,
) {
  if (snapshot.hasData) {
    return success(context, snapshot.data!);
  } else if (snapshot.connectionState == ConnectionState.waiting) {
    return loading ??
        Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
  } else if (snapshot.hasError) {
    return error!(context, snapshot.error) ??
        Center(
          child: SelectableText(
            snapshot.error.toString(),
          ),
        );
  } else {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: failed ??
          Center(
            child: Text(context.locale.errorUnknown),
          ),
    );
  }
}
