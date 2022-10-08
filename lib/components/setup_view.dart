import 'dart:async';

import 'package:allo/components/empty.dart';
import 'package:allo/logic/core.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final setupButtonTheme = ButtonStyle(
  minimumSize: const MaterialStatePropertyAll(
    Size.fromHeight(40),
  ),
  shape: MaterialStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
);

typedef SetupViewChildBuilder = List<Widget> Function(
  BuildContext context,
  FutureOr<void> Function()? callback,
);

/// A class member that is mostly passed by [SetupView]'s [builder] method, to help keep the
/// parameter passing clean and to add parameters on demand, based on requests, without modifying
/// the method.
class SetupProps {
  const SetupProps({
    required this.callback,
    required this.innerWidgetContext,
  });
  final FutureOr<void> Function()? callback;
  final BuildContext innerWidgetContext;
}

/// Documentation will be implemented very soon.
/// Note: the action you are going
class SetupView extends HookConsumerWidget {
  const SetupView({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.builder,
    super.key,
  });
  final IconData icon;
  final Widget title;
  final Widget description;
  final FutureOr<void> Function()? action;
  final List<Widget> Function(SetupProps props)? builder;

  @override
  Widget build(context, ref) {
    final progressState = useState(false);
    Future<void> preparedCallback() async {
      if (action != null) {
        try {
          progressState.value = true;
          await action!();
        } finally {
          progressState.value = false;
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
          child: Column(
            children: [
              const Expanded(child: SizedBox()),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: context.textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                    child: title,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  DefaultTextStyle(
                    style: context.textTheme.bodyLarge!
                        .copyWith(color: context.colorScheme.onSurfaceVariant),
                    child: description,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10)),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: progressState.value
                              ? SizedBox.fromSize(child: const ProgressBar())
                              : const Empty(),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 5)),
              const Expanded(
                child: SizedBox(),
              ),
              if (builder != null) ...[
                SingleChildScrollView(
                  child: Column(
                    children: builder!.call(
                      SetupProps(
                        callback: preparedCallback,
                        innerWidgetContext: context,
                      ),
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(top: 5)),
                const Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
              ],
              Row(
                children: [
                  if (context.canPop()) ...[
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.navigate_before_rounded),
                        label: const Text('Back'),
                        style: setupButtonTheme,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                  ],
                  Expanded(
                    child: FilledButton(
                      style: setupButtonTheme,
                      onPressed: preparedCallback,
                      child: const Text('Continuă'),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
