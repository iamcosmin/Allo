import 'package:allo/components/space.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/logic/core.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

//TODO: Handle big font sizes on small screens.
//TODO: Handle big screen size split
class SetupPage extends HookConsumerWidget {
  const SetupPage({
    required this.title,
    required this.body,
    required this.action,
    this.icon = Icons.warning,
    this.subtitle,
    this.customButtonText,
    @Deprecated('Handle title using [title] parameter and any other subtitles with the [subtitle] parameter.')
        this.header,
    this.nextRoute,
    this.isRoutePermanent = false,
    this.isNavigationHandled = false,
    this.alignment = CrossAxisAlignment.center,
    this.debug,
    Key? key,
  })  : assert(
          (nextRoute != null && isNavigationHandled == false) ||
              (nextRoute == null && isNavigationHandled == true),
          'You cannot provide nextRoute if navigation is handled by your own library.',
        ),
        super(key: key);

  final String title;
  final String? subtitle;
  final String? customButtonText;
  final IconData icon;
  final List<Widget>? header;
  final List<Widget> body;
  final Future<bool> Function() action;
  final Widget? nextRoute;
  final bool isRoutePermanent;
  final bool isNavigationHandled;
  final CrossAxisAlignment alignment;
  final Widget? debug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = S.of(context);
    final loading = useState(false);
    final buttonText = customButtonText ?? locales.setupNext;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 15,
                left: 40,
                right: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        icon,
                        size: body.isNotEmpty ? 40 : 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Space(2),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: body.isNotEmpty ? 30 : 45,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const Space(3),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      Space(body.isNotEmpty ? 5 : 5),
                    ],
                  ),
                  if (body.isNotEmpty) ...[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Column(
                            crossAxisAlignment: alignment,
                            children: body,
                          ),
                        ),
                      ),
                    ),
                  ],
                  Container(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Visibility(
                            visible: Navigator.of(context).canPop(),
                            child: OutlinedButton.icon(
                              icon:
                                  const Icon(Icons.arrow_back_ios_new_outlined),
                              onPressed: () => Navigator.of(context).pop(),
                              label: const Text('Înapoi'),
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.standard,
                              ),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(left: 10)),
                        Expanded(
                          child: ElevatedButton(
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.standard,
                            ),
                            child: PageTransitionSwitcher(
                              duration: const Duration(milliseconds: 100),
                              transitionBuilder:
                                  (child, animation, secondaryAnimation) {
                                return SharedAxisTransition(
                                  animation: animation,
                                  secondaryAnimation: secondaryAnimation,
                                  fillColor: Colors.transparent,
                                  transitionType:
                                      SharedAxisTransitionType.horizontal,
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
                                      buttonText,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ),
                            ),
                            onPressed: () async {
                              loading.value = true;
                              final value = await action();
                              if (value) {
                                loading.value = false;
                                if (!isNavigationHandled) {
                                  if (isRoutePermanent) {
                                    await Core.navigation.pushPermanent(
                                      context: context,
                                      route: nextRoute!,
                                    );
                                  } else {
                                    Core.navigation.push(
                                      route: nextRoute!,
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
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
