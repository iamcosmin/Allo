import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide ThemeData, Colors;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interface/home/stack_navigator.dart';
import 'interface/login/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final _kSharedPreferences = await SharedPreferences.getInstance();
  if (kIsWeb) {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance.getToken(
      vapidKey:
          'BAx5uT7szCuYzwq9fLUNwS9-OF-GwOa4eGAb5J3jfl2d3e3L2b354oRm89KQ6sUbiEsK5YLPJoOs0n25ibcGbO8',
    );
  } else {
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'Notificări de conversații', // title
      'Acest canal este folosit pentru notificări din conversații', // description
      importance: Importance.max,
    );
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  runApp(
    ProviderScope(
      overrides: [
        Repositories.sharedPreferences.overrideWithValue(_kSharedPreferences),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends HookWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    useEffect(() {}, const []);
    final theme = useProvider(appThemeProvider);
    final darkState = useProvider(darkMode);
    return CupertinoApp(
      title: 'Allo',
      theme: theme.getAppThemeData(context, darkState),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot s) {
          if (s.hasData) {
            return StackNavigator();
          } else {
            return Welcome();
          }
        },
      ),
    );
  }
}
