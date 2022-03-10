import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/main_setup.dart';
import 'package:allo/logic/client/hooks.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/client/preferences/preferences.dart';
import 'package:allo/logic/client/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'interface/home/tabbed_navigator.dart';
import 'logic/client/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAyLt2_FAHc0I2c1iBLH_MxWzo2kllSvA8",
      authDomain: "allo-ms.firebaseapp.com",
      projectId: "allo-ms",
      storageBucket: "allo-ms.appspot.com",
      messagingSenderId: "1049075385887",
      appId: "1:1049075385887:web:89f4887e574f8b93f2372a",
      measurementId: "G-N5D9CRB413",
    ),
  );
  if (!kIsWeb) {
    await Core.notifications.setupNotifications();
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }
  FirebaseRemoteConfig.instance.fetchAndActivate();
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
      overrides: await Core.getOverrides(),
      child: const InnerApp(),
    ),
  );
}

class InnerApp extends HookConsumerWidget {
  const InnerApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkState = usePreference(ref, darkMode);
    return MaterialApp(
      title: 'Allo',
      debugShowCheckedModeBanner: false,
      navigatorKey: Core.navigatorKey,
      themeMode: darkState.preference ? ThemeMode.dark : ThemeMode.light,
      theme: theme(Brightness.light, ref, context),
      darkTheme: theme(Brightness.dark, ref, context),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.hasData) {
            return TabbedNavigator();
          } else if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else {
            return const Setup();
          }
        },
      ),
    );
  }
}
