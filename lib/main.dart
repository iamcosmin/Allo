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
  await Firebase.initializeApp();
  if (!kIsWeb) {
    await Core.notifications.setupNotifications();
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }
  final remoteConfig = RemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: Duration(seconds: 60),
    minimumFetchInterval: Duration(hours: 1),
  ));
  await remoteConfig.fetchAndActivate();
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
  AwesomeNotifications().actionStream.listen((ReceivedAction event) async {
    await Core.navigation.push(
      context: navigatorKey.currentState!.context,
      route: ChatScreen(
        chatType: getChatTypeFromString(event.payload!['chatType']!) ??
            ChatType.group,
        title: event.payload!['chatName']!,
        chatId: event.payload!['chatId']!,
      ),
    );
  });
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
    final material3InApp = usePreference(ref, material3App, context);
    const _scrollBehavior = MaterialScrollBehavior(
        androidOverscrollIndicator: AndroidOverscrollIndicator.stretch);
    useEffect(() {
      FirebaseRemoteConfig.instance.fetchAndActivate();
      return;
    }, const []);
    return MaterialApp(
      title: 'Allo',
      navigatorKey: navigatorKey,
      scrollBehavior: _scrollBehavior,
      themeMode: darkState ? ThemeMode.dark : ThemeMode.light,
      theme: material3InApp.preference == false ? oldLightTheme : lightTheme,
      darkTheme: material3InApp.preference == false ? oldDarkTheme : darkTheme,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('ro', '')],
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
