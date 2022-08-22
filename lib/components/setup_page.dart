import 'dart:async';

import 'package:allo/components/empty.dart';
import 'package:allo/components/space.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _kDividerHeroTag =
    "SETUP_PAGE_WIDGET_VERTICAL_DIVIDER_HERO_TAG_ansd9fn9w4nfawesf";
const buttonBarHeroTag =
    "SETUP_PAGE_WIDGET_BUTTON_BAR_HERO_TAG_nas94nefa9we934fn9";
const _kDefaultPadding =
    EdgeInsets.only(left: 25, right: 25, top: 5, bottom: 5);

final setupLoading = StateProvider((ref) => false);

abstract class _SetupScreen extends StatelessWidget {
  const _SetupScreen({
    required this.icon,
    required this.title,
    required this.actions,
    required this.body,
    required this.subtitle,
    required super.key,
  });
  final IconData icon;
  final Widget title;
  final Widget? subtitle;
  final List<Widget>? body;
  final SetupActions actions;
}

extension X on BuildContext {
  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }
}

extension Y on List? {
  bool get isNullOrEmpty {
    if (this != null && this!.isNotEmpty) {
      return false;
    } else {
      return true;
    }
  }
}

enum ActionSize { small, medium, large }

enum ActionFlow { horizontal, vertical }

enum ActionFill { empty, filled }

class SetupAction {
  const SetupAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.size = ActionSize.large,
    this.fill = ActionFill.filled,
  });
  final String label;
  final Icon? icon;
  final ActionSize size;
  final ActionFill fill;
  final FutureOr<void> Function() onTap;
}

class SetupActions {
  SetupActions({
    required this.actions,
    this.flow = ActionFlow.vertical,
  }) : assert(actions.isNotEmpty, 'There needs to be at least one action.');
  final ActionFlow flow;
  final List<SetupAction> actions;
}

class SetupPage extends StatelessWidget {
  const SetupPage({
    required this.icon,
    required this.title,
    @Deprecated('') required this.action,
    this.subtitle,
    this.body,
    this.actions,
    super.key,
  });
  final IconData icon;
  final Widget title;
  final Widget? subtitle;
  final List<Widget>? body;
  @Deprecated('Please use actions.')
  final FutureOr<void> Function() action;
  final SetupActions? actions;

  @override
  Widget build(BuildContext context) {
    final setupActions = actions == null || actions!.actions.isNullOrEmpty
        ? SetupActions(
            actions: [
              SetupAction(
                label: context.locale.setupNext,
                onTap: action,
              )
            ],
            flow: ActionFlow.horizontal,
          )
        : actions!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: ModalRoute.of(context)!.canPop
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: BackButton(),
              )
            : const Empty(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 1000) {
              return _LargeScreen(
                icon: icon,
                title: title,
                subtitle: subtitle,
                body: body,
                actions: setupActions,
              );
            } else {
              return _SmallScreen(
                icon: icon,
                title: title,
                actions: setupActions,
                body: body,
                subtitle: subtitle,
              );
            }
          },
        ),
      ),
    );
  }
}

class _TitleWidget extends HookConsumerWidget {
  const _TitleWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isBodyNullOrEmpty,
    required super.key,
  });
  final IconData icon;
  final Widget title;
  final Widget? subtitle;
  final bool isBodyNullOrEmpty;

  @override
  Widget build(context, ref) {
    final loading = ref.watch(setupLoading);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: context.theme.colorScheme.primary,
          size: 50,
        ),
        const Space(2),
        DefaultTextStyle(
          style: context.theme.textTheme.headlineLarge!.copyWith(
            color: context.theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (subtitle != null) ...[
                const Space(1),
                DefaultTextStyle(
                  style: context.theme.textTheme.bodyMedium!.copyWith(
                    color: context.theme.colorScheme.onSurfaceVariant,
                  ),
                  child: subtitle!,
                )
              ]
            ],
          ),
        ),
        const Space(1),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: loading ? 5 : 0,
          child: LinearProgressIndicator(value: loading ? null : 0),
        )
      ],
    );
  }
}

class _ButtonBar extends HookConsumerWidget {
  const _ButtonBar({
    required this.actions,
  });
  final SetupActions actions;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonStyle = ButtonStyle(
      visualDensity: VisualDensity.comfortable,
      minimumSize: MaterialStateProperty.all(
        const Size.fromHeight(50),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
    final elevatedButtonStyle = buttonStyle.copyWith(
      backgroundColor: MaterialStateProperty.all(
        context.colorScheme.primary,
      ),
      foregroundColor: MaterialStateProperty.all(
        context.colorScheme.onPrimary,
      ),
    );
    FutureOr<void> onTap(FutureOr<void> Function() onTap) async {
      ref.read(setupLoading.notifier).state = true;
      await onTap();
      ref.read(setupLoading.notifier).state = false;
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                for (var action in actions.actions) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Builder(
                      builder: (_) {
                        switch (action.fill) {
                          case ActionFill.empty:
                            if (action.icon != null) {
                              return TextButton.icon(
                                onPressed: () async =>
                                    await onTap(action.onTap),
                                icon: action.icon!,
                                label: Text(action.label),
                                style: buttonStyle,
                              );
                            } else {
                              return TextButton(
                                onPressed: () async =>
                                    await onTap(action.onTap),
                                style: buttonStyle,
                                child: Text(action.label),
                              );
                            }
                          case ActionFill.filled:
                            if (action.icon != null) {
                              return ElevatedButton.icon(
                                onPressed: () async =>
                                    await onTap(action.onTap),
                                icon: action.icon!,
                                label: Text(action.label),
                                style: elevatedButtonStyle,
                              );
                            } else {
                              return ElevatedButton(
                                onPressed: () async =>
                                    await onTap(action.onTap),
                                style: elevatedButtonStyle,
                                child: Text(action.label),
                              );
                            }
                        }
                      },
                    ),
                  )
                ],

                // loading.value = true;
                // await action();
                // loading.value = false;

                // PageTransitionSwitcher(
                //   transitionBuilder: (child, animation, secondaryAnimation) {
                //     return FadeThroughTransition(
                //       animation: animation,
                //       fillColor: Colors.transparent,
                //       secondaryAnimation: secondaryAnimation,
                //       child: child,
                //     );
                //   },
                //   child: loading.value
                //       ? LayoutBuilder(
                //           builder: (context, constraints) {
                //             return SizedBox.fromSize(
                //               size: const Size(25, 25),
                //               child: CircularProgressIndicator(
                //                 color: context.colorScheme.onPrimary,
                //                 strokeWidth: 3,
                //               ),
                //             );
                //           },
                //         )
                //       : Text(buttonText),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallScreen extends _SetupScreen {
  const _SmallScreen({
    required super.icon,
    required super.title,
    required super.actions,
    required super.body,
    required super.subtitle,
    // ignore: unused_element
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _kDefaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _TitleWidget(
                key: key,
                icon: icon,
                title: title,
                subtitle: subtitle,
                isBodyNullOrEmpty: body.isNullOrEmpty,
              ),
            ),
          ),
          const Space(2),
          if (!body.isNullOrEmpty) ...[
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: body!,
              ),
            ),
          ],
          const Space(2),
          _ButtonBar(
            actions: actions,
          )
        ],
      ),
    );
  }
}

class _LargeScreen extends _SetupScreen {
  const _LargeScreen({
    required super.icon,
    required super.title,
    required super.actions,
    required super.body,
    required super.subtitle,
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: _kDefaultPadding,
                  child: _TitleWidget(
                    key: key,
                    icon: icon,
                    title: title,
                    subtitle: subtitle,
                    isBodyNullOrEmpty: body.isNullOrEmpty,
                  ),
                ),
              ),
              Hero(
                tag: _kDividerHeroTag,
                child: VerticalDivider(
                  color: context.theme.colorScheme.surfaceVariant,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: _kDefaultPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (!body.isNullOrEmpty) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: body!,
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      _ButtonBar(
                        actions: actions,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
