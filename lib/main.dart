import 'package:allo/firebase_options.dart';
import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/email_not_verified.dart';
import 'package:allo/interface/login/main_setup.dart';
import 'package:allo/logic/client/preferences/manager.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme/page_transitions/slide_page_transition.dart';
import 'package:allo/logic/client/theme/theme.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/models/auth_state.dart';
import 'package:animations/animations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'interface/home/tabbed_navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    await Notifications.setupNotifications();
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }
  await FirebaseRemoteConfig.instance.fetchAndActivate();
  // await FirebaseMessaging.instance.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );
  // await FirebaseMessaging.instance.getToken(
  //   vapidKey:
  //       'BAx5uT7szCuYzwq9fLUNwS9-OF-GwOa4eGAb5J3jfl2d3e3L2b354oRm89KQ6sUbiEsK5YLPJoOs0n25ibcGbO8',
  // );
  runApp(
    ProviderScope(
      overrides: await Keys.getOverrides(),
      child: const InnerApp(),
    ),
  );
}

class InnerApp extends HookConsumerWidget {
  const InnerApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkState = useSetting(ref, darkMode);
    final authState = ref.watch(Core.auth.stateProvider);
    useEffect(
      () {
        const Notifications().ensureListenersActive();
        return;
      },
      const [],
    );
    return MaterialApp(
      title: 'Allo',
      debugShowCheckedModeBanner: false,
      navigatorKey: Navigation.navigatorKey,
      scaffoldMessengerKey: Keys.scaffoldMessengerKey,
      themeMode: ThemeMode.values.firstWhere(
        (element) => darkState.setting == element.toString(),
      ),
      theme: theme(Brightness.light, ref, context),
      darkTheme: theme(Brightness.dark, ref, context),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: authState.when(
        data: (data) {
          return PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return SlidePageTransition(
                secondaryAnimation: secondaryAnimation,
                animation: primaryAnimation,
                child: child,
              );
            },
            child: Builder(
              builder: (context) {
                switch (data) {
                  case AuthState.emailNotVerified:
                    return const EmailNotVerifiedPage(
                      nextRoute: TabbedNavigator(),
                    );
                  case AuthState.signedOut:
                    return const Setup();
                  case AuthState.signedIn:
                    return const TabbedNavigator();
                }
              },
            ),
          );
        },
        error: (_, __) => const Center(
          child: Text('Error!'),
        ),
        loading: () {
          return const Scaffold(
            body: Center(
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
      // home: StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snap) {
      //     if (snap.hasData) {
      //       return const TabbedNavigator();
      //     } else if (snap.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(
      //         body: Center(
      //           child: SizedBox(
      //             height: 60,
      //             width: 60,
      //             child: CircularProgressIndicator(),
      //           ),
      //         ),
      //       );
      //     } else {
      //       return const Setup();
      //     }
      //   },
      // ),
    );
  }
}
