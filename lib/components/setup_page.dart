import 'dart:async';

import 'package:allo/components/space.dart';
import 'package:allo/logic/core.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _kDividerHeroTag =
    "SETUP_PAGE_WIDGET_VERTICAL_DIVIDER_HERO_TAG_ansd9fn9w4nfawesf";
const _kTitleHeroTag =
    "SETUP_PAGE_WIDGET_TITLEWITHICON_HERO_TAG_nasd9f94nf9aw499w3en";
const buttonBarHeroTag =
    "SETUP_PAGE_WIDGET_BUTTON_BAR_HERO_TAG_nas94nefa9we934fn9";
const _kDefaultPadding = EdgeInsets.only(left: 20, right: 20);

abstract class _SetupScreen extends StatelessWidget {
  const _SetupScreen({
    required this.icon,
    required this.title,
    required this.action,
    required this.body,
    required this.subtitle,
    required this.actionText,
    required super.key,
  });
  final IconData icon;
  final Widget title;
  final Widget? subtitle;
  final List<Widget>? body;

  final FutureOr<void> Function() action;
  final String? actionText;
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

class SetupPage extends StatelessWidget {
  const SetupPage({
    required this.icon,
    required this.title,
    required this.action,
    this.subtitle,
    this.body,
    this.actionText,
    super.key,
  });
  final IconData icon;
  final Widget title;
  final Widget? subtitle;
  final List<Widget>? body;
  final FutureOr<void> Function() action;
  final String? actionText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1000) {
                return _LargeScreen(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                  actionText: actionText,
                  body: body,
                  action: action,
                );
              } else {
                return _SmallScreen(
                  icon: icon,
                  title: title,
                  action: action,
                  body: body,
                  actionText: actionText,
                  subtitle: subtitle,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class _TitleWidget extends StatelessWidget {
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
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: context.theme.colorScheme.primary,
          size: 50,
        ),
        const Space(3),
        DefaultTextStyle(
          style: context.theme.textTheme.displaySmall!.copyWith(
            color: context.theme.colorScheme.onSurface,
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
      ],
    );
  }
}

class _ButtonBar extends HookConsumerWidget {
  const _ButtonBar({
    required this.action,
    required this.actionText,
  });
  final FutureOr<void> Function() action;
  final String? actionText;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonText = actionText ?? context.locale.setupNext;
    final loading = useState(false);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          if (context.navigator.canPop()) ...[
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.arrow_back_ios_new),
                label: Text(context.locale.back),
                onPressed: () {
                  context.navigator.pop();
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.comfortable,
                  fixedSize: MaterialStateProperty.all(
                    const Size.fromHeight(40),
                  ),
                ),
              ),
            ),
            const Space(
              7.5,
              direction: Direction.horizontal,
            ),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                loading.value = true;
                await action();
                loading.value = false;
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.comfortable,
                fixedSize: MaterialStateProperty.all(
                  const Size.fromHeight(40),
                ),
              ),
              child: PageTransitionSwitcher(
                transitionBuilder: (child, animation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                child: loading.value
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 300) {
                            return LinearProgressIndicator(
                              color: context.colorScheme.onSurface,
                              backgroundColor: Colors.transparent,
                              minHeight: 5,
                            );
                          }
                          return SizedBox.fromSize(
                            size: const Size(20, 20),
                            child: CircularProgressIndicator(
                              color: context.colorScheme.primary,
                              strokeWidth: 3,
                            ),
                          );
                        },
                      )
                    : Text(buttonText),
              ),
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
    required super.action,
    required super.body,
    required super.actionText,
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
          Padding(
            padding: _kDefaultPadding,
            child: _TitleWidget(
              key: key,
              icon: icon,
              title: title,
              subtitle: subtitle,
              isBodyNullOrEmpty: body.isNullOrEmpty,
            ),
          ),
          const Space(5),
          if (!body.isNullOrEmpty) ...[
            Expanded(
              child: Padding(
                padding: _kDefaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: body!,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _ButtonBar(
              action: action,
              actionText: actionText,
            ),
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
    required super.action,
    required super.body,
    required super.actionText,
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
                        action: action,
                        actionText: actionText,
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
