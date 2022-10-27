import 'package:allo/interface/home/chat/chat.dart';
import 'package:allo/interface/home/home.dart';
import 'package:allo/interface/home/navigation_view.dart';
import 'package:allo/interface/home/settings.dart';
import 'package:allo/interface/home/settings/about.dart';
import 'package:allo/interface/home/settings/account/account.dart';
import 'package:allo/interface/home/settings/debug.dart';
import 'package:allo/interface/home/settings/debug/account_info.dart';
import 'package:allo/interface/home/settings/debug/experiments/create_chat.dart';
import 'package:allo/interface/home/settings/debug/experiments/example_sliver.dart';
import 'package:allo/interface/home/settings/debug/experiments/typingbubble.dart';
import 'package:allo/interface/home/settings/debug/test_notifications.dart';
import 'package:allo/interface/home/settings/personalise.dart';
import 'package:allo/interface/login/existing/enter_password.dart';
import 'package:allo/interface/login/intro.dart';
import 'package:allo/interface/login/login.dart';
import 'package:allo/interface/login/new/setup_name.dart';
import 'package:allo/interface/login/new/setup_password.dart';
import 'package:allo/interface/login/new/setup_username.dart';
import 'package:allo/interface/verification.dart';
import 'package:allo/logic/backend/setup/login.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/auth_state.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../interface/home/chat/chat_details.dart';
import '../../models/chat.dart';

final rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'Root Navigator Key');
final _navbarNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'Navigation Bar Navigator Key');
const _trustedEmails = ['i.am.cosmin.bicc@gmail.com', 'nutua29@gmail.com'];

class Routes {
  static const chats = 'chats';
  static const chat = 'chat';
  static const chatDetails = 'chatDetails';
}

Widget _fadeThroughTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeThroughTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    fillColor: context.colorScheme.surface,
    child: child,
  );
}

class NavigationBarPage extends CustomTransitionPage {
  const NavigationBarPage(
    Widget child, {
    super.key,
  }) : super(
          child: child,
          transitionsBuilder: _fadeThroughTransition,
        );
}

final routing = Provider<GoRouter>(
  (ref) {
    final routes = <RouteBase>[
      ShellRoute(
        navigatorKey: _navbarNavigatorKey,
        builder: (context, state, child) {
          return NavigationView(
            key: state.pageKey,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/chats',
            parentNavigatorKey: _navbarNavigatorKey,
            pageBuilder: (context, state) {
              return NavigationBarPage(
                const Home(),
                key: state.pageKey,
              );
            },
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  if (state.extra! is Chat) {
                    // ignore: cast_nullable_to_non_nullable
                    return ChatScreen(
                      chat: state.extra! as Chat,
                    );
                  } else {
                    throw Exception(
                      'At the moment, the chat id passed in the URL is not used. Please open chats from the chatList.',
                    );
                  }
                },
                routes: [
                  GoRoute(
                    path: 'details',
                    name: Routes.chatDetails,
                    builder: (context, state) {
                      if (state.extra! is Chat) {
                        return ChatDetails(
                          chat: state.extra! as Chat,
                        );
                      } else {
                        throw Exception(
                          'At the moment, the chat id passed in the URL is not used. Please open chats from the chatList.',
                        );
                      }
                    },
                  )
                ],
              ),
              GoRoute(
                path: 'create',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const CreateChat(),
              )
            ],
          ),
          GoRoute(
            path: '/settings',
            parentNavigatorKey: _navbarNavigatorKey,
            pageBuilder: (context, state) => NavigationBarPage(
              const Settings(),
              key: state.pageKey,
            ),
            routes: [
              GoRoute(
                path: 'account',
                parentNavigatorKey: rootNavigatorKey,
                pageBuilder: (context, state) {
                  return MaterialPage(
                    key: state.pageKey,
                    name: 'Account',
                    child: const AccountSettingsPage(),
                  );
                },
              ),
              GoRoute(
                path: 'about',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const AboutPage(),
                routes: [
                  GoRoute(
                    path: 'debug',
                    pageBuilder: (context, state) {
                      return const MaterialPage(
                        key: ValueKey('DEBUG PUSHED!'),
                        child: DebugPage(
                          key: ValueKey('HERE IS DEBUG!'),
                        ),
                        name: 'Debug',
                      );
                    },
                    redirect: (context, state) => _trustedEmails
                            .contains(FirebaseAuth.instance.currentUser?.email)
                        ? null
                        : '/chats',
                    routes: [
                      // GoRoute(
                      //   path: 'testapp',
                      //   builder: (context, state) => MyApp(),
                      // ),
                      GoRoute(
                        path: 'typing',
                        builder: (context, state) => const ExampleIsTyping(),
                      ),
                      GoRoute(
                        path: 'account-info',
                        builder: (context, state) => const AccountInfo(),
                      ),
                      GoRoute(
                        path: 'slivers',
                        builder: (context, state) => const ExampleSliver(),
                      ),
                      GoRoute(
                        path: 'notifications',
                        builder: (context, state) =>
                            const TestNotificationsPage(),
                      )
                    ],
                  )
                ],
              ),
              GoRoute(
                path: 'personalise',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const PersonalisePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/start',
        builder: (context, state) => const IntroPage(),
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const LoginPage(),
            routes: [
              GoRoute(
                path: 'password',
                builder: (context, state) => const EnterPassword(),
              )
            ],
          ),
          GoRoute(
            path: 'signup',
            redirect: (context, state) =>
                ref.read(signupState).email != null ? null : '/start',
            builder: (context, state) => const SetupName(),
            routes: [
              GoRoute(
                path: 'username',
                redirect: (context, state) =>
                    ref.read(signupState).name != null ? null : '/start',
                builder: (context, state) => const SetupUsername(),
              ),
              GoRoute(
                path: 'password',
                redirect: (context, state) {
                  final state = ref.read(signupState);
                  if (state.name != null &&
                      state.username != null &&
                      state.email != null) {
                    return null;
                  } else {
                    return '/start';
                  }
                },
                builder: (context, state) => const SetupPassword(),
              ),
            ],
          )
        ],
      ),
      GoRoute(
        path: '/verification',
        builder: (context, state) => const EmailNotVerifiedPage(),
      )
    ];
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      refreshListenable: _RouterNotifier(ref),
      debugLogDiagnostics: kDebugMode ? true : false,
      initialLocation: '/chats',
      routes: routes,
      redirect: (context, state) {
        final authState = ref.read(Core.auth.stateProvider);
        final path = state.location;
        if (!path.startsWith('/start') &&
            authState.value == AuthState.signedOut) {
          return '/start';
        }
        if (!path.startsWith('/verification') &&
            authState.value == AuthState.emailNotVerified) {
          return '/verification';
        }
        if ((path.startsWith('/start') ||
                path.startsWith('/verification') ||
                path.startsWith('/loading')) &&
            authState.value == AuthState.signedIn) {
          return '/chats';
        }
        return null;
      },
    );
  },
);

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  _RouterNotifier(this._ref) {
    _ref.listen(Core.auth.stateProvider, (_, __) {
      if (_ != __) {
        notifyListeners();
      }
    });
  }
}
