import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SetupPage extends HookConsumerWidget {
  const SetupPage(
      {required this.header,
      required this.body,
      required this.action,
      this.nextRoute,
      this.isRoutePermanent = false,
      this.isNavigationHandled = false,
      this.alignment = CrossAxisAlignment.center,
      Key? key})
      : assert(
            (nextRoute != null && isNavigationHandled == false) ||
                (nextRoute == null && isNavigationHandled == true),
            'You cannot provide nextRoute if navigation is handled by your own library.'),
        super(key: key);
  final List<Widget> header;
  final List<Widget> body;
  final Future<bool> Function() action;
  final Widget? nextRoute;
  final bool isRoutePermanent;
  final bool isNavigationHandled;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final loading = useState(false);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: header,
                        ),
                      ),
                    ],
                  ),
                ),
                if (body != []) ...[
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: alignment,
                      children: body,
                    ),
                  ),
                ],
                Expanded(
                  flex: 0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (Navigator.of(context).canPop()) ...[
                            Expanded(
                              flex: 1,
                              child: OutlinedButton.icon(
                                icon: const Icon(
                                    Icons.arrow_back_ios_new_outlined),
                                onPressed: () => Navigator.of(context).pop(),
                                label: const Text('Înapoi'),
                                style: const ButtonStyle(
                                  visualDensity: VisualDensity.standard,
                                ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                          ],
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.standard,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 100),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: loading.value
                                    ? SizedBox(
                                        height: 23,
                                        width: 23,
                                        child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Text(
                                        locales.setupNext,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            backgroundColor:
                                                Colors.transparent),
                                      ),
                              ),
                              onPressed: () async {
                                loading.value = true;
                                final value = await action();
                                if (value) {
                                  loading.value = false;
                                  if (!isNavigationHandled) {
                                    if (isRoutePermanent) {
                                      Core.navigation.pushPermanent(
                                        context: context,
                                        route: nextRoute!,
                                      );
                                    } else {
                                      Core.navigation.push(
                                        context: context,
                                        route: nextRoute!,
                                        login: true,
                                      );
                                    }
                                  }
                                } else {
                                  loading.value = false;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: header,
                        ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  indent: 10,
                  endIndent: 10,
                ),
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      if (body != []) ...[
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: alignment,
                            children: body,
                          ),
                        ),
                      ],
                      Expanded(
                        flex: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (Navigator.of(context).canPop()) ...[
                                  Expanded(
                                    flex: 1,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                          Icons.arrow_back_ios_new_outlined),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      label: const Text('Înapoi'),
                                      style: const ButtonStyle(
                                        visualDensity: VisualDensity.standard,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(left: 10)),
                                ],
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    style: const ButtonStyle(
                                      visualDensity: VisualDensity.standard,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      transitionBuilder: (child, animation) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      child: loading.value
                                          ? SizedBox(
                                              height: 23,
                                              width: 23,
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                                strokeWidth: 3,
                                              ),
                                            )
                                          : Text(
                                              locales.setupNext,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  backgroundColor:
                                                      Colors.transparent),
                                            ),
                                    ),
                                    onPressed: () async {
                                      loading.value = true;
                                      final value = await action();
                                      if (value) {
                                        loading.value = false;
                                        if (!isNavigationHandled) {
                                          if (isRoutePermanent) {
                                            Core.navigation.pushPermanent(
                                              context: context,
                                              route: nextRoute!,
                                            );
                                          } else {
                                            Core.navigation.push(
                                              context: context,
                                              route: nextRoute!,
                                              login: true,
                                            );
                                          }
                                        }
                                      } else {
                                        loading.value = false;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }
        },
      ),
    );
  }
}
