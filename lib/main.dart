import 'dart:io';

import 'package:allo/generated/l10n.dart';
import 'package:allo/interface/login/main_setup.dart';
import 'package:allo/logic/core.dart';
import 'package:allo/logic/preferences.dart';
import 'package:allo/logic/theme.dart';
import 'package:allo/logic/themes.dart';
import 'package:allo/logic/types.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interface/home/chat/chat.dart';
import 'interface/home/tabbed_navigator.dart';
import 'logic/chat/chat.dart';
import 'logic/notifications.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
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
  } else if (Platform.isAndroid) {
    // Todo: Migrate to dart only initialisation for android.
    await Firebase.initializeApp();
  }

  if (!kIsWeb) {
    await Core.notifications.setupNotifications();
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }
  final _kSharedPreferences = await SharedPreferences.getInstance();
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
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_kSharedPreferences),
      ],
      child: const InnerApp(),
    ),
  );
}

class InnerApp extends HookConsumerWidget {
  const InnerApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkState = ref.watch(darkMode);
    const _scrollBehavior = MaterialScrollBehavior(
        androidOverscrollIndicator: AndroidOverscrollIndicator.stretch);
    useEffect(() {
      FirebaseRemoteConfig.instance.fetchAndActivate();
      return;
    }, const []);
    useNotificationListener(context);
    return MaterialApp(
      title: 'Allo',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scrollBehavior: _scrollBehavior,
      themeMode: darkState ? ThemeMode.dark : ThemeMode.light,
      theme: theme(Brightness.light, ref, context),
      darkTheme: theme(Brightness.dark, ref, context),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: CupertinoTheme(
        data: CupertinoThemeData(
            brightness: darkState ? Brightness.dark : Brightness.light,
            primaryColor: theme(darkState ? Brightness.dark : Brightness.light,
                    ref, context)
                .colorScheme
                .primary,
            scaffoldBackgroundColor: theme(
                    darkState ? Brightness.dark : Brightness.light,
                    ref,
                    context)
                .colorScheme
                .surface),
        child: StreamBuilder(
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
      ),
    );
  }
}
