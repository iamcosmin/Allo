import 'package:allo/components/deferred.dart';
import 'package:allo/interface/login/main_setup.dart';
import 'package:allo/repositories/chats_repository.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interface/home/stack_navigator.dart';

Future _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['uid'] != FirebaseAuth.instance.currentUser!.uid) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: int.parse(
              message.data['toChat'].replaceAll(RegExp(r'[a-zA-Z]'), '')),
          title: (message.data['type'] ?? 'group') == ChatType.group
              ? message.data['chatName']
              : message.data['senderName'],
          body: (message.data['chatType'] ?? 'private') == ChatType.private
              ? message.data['text']
              : '${message.data['senderName']}: ${message.data['text']}',
          channelKey: 'conversations',
          notificationLayout: NotificationLayout.Messaging,
          createdSource: NotificationSource.Firebase,
          payload: {
            'chatId': message.data['toChat'],
            'chatName': message.data['chatName'],
            'chatType': message.data['type'] ?? ChatType.group,
          }),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        'resource://drawable/res_notification',
        [
          NotificationChannel(
            channelKey: 'conversations',
            channelName: 'Conversații',
            channelDescription: 'Notificări din conversații.',
            defaultColor: Colors.blue,
            ledColor: Colors.blue,
            playSound: true,
            importance: NotificationImportance.Max,
          )
        ]);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  }
  await Firebase.initializeApp();
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
        Repositories.sharedPreferences.overrideWithValue(_kSharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends HookWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  Future<void> performUpdate(context) async {
    await InAppUpdate.checkForUpdate().then((value) async {
      if (value.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate().then(
          (value) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(hours: 5),
              behavior: SnackBarBehavior.floating,
              content: const Text('Actualizarea este pregătită.'),
              action: SnackBarAction(
                label: 'Instalează',
                onPressed: () async {
                  await InAppUpdate.completeFlexibleUpdate();
                },
              ),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (!kIsWeb) {
        performUpdate(context);
      }
    }, []);
    final darkState = useProvider(darkMode);
    return MaterialApp(
        title: 'Allo',
        scrollBehavior: const MaterialScrollBehavior(
            /* androidOverscrollIndicator: AndroidOverscrollIndicator.stretch*/),
        themeMode: darkState == true ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                brightness: Brightness.light,
                accentColor: const Color(0xFF1A76C6)),
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white, foregroundColor: Colors.black),
            scaffoldBackgroundColor: Colors.white,
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.grey.shade300,
                selectedItemColor: const Color(0xFF1A76C6)),
            // navigationBarTheme: NavigationBarThemeData(
            //     indicatorColor: const Color(0xFF1A76C6),
            //     backgroundColor: Colors.grey.shade300),
            fontFamily: 'VarDisplay'),
        darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
                brightness: Brightness.dark,
                accentColor: const Color(0xFF49B3EA)),
            brightness: Brightness.dark,
            appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade900),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.grey.shade800,
                unselectedItemColor: Colors.white,
                selectedItemColor: const Color(0xFF49B3EA)),
            // navigationBarTheme: NavigationBarThemeData(
            //     indicatorColor: const Color(0xFF49B3EA),
            //     backgroundColor: Colors.grey.shade800),
            fontFamily: 'VarDisplay',
            scaffoldBackgroundColor: Colors.black),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snap) {
            if (snap.hasData) {
              return StackNavigator();
            } else if (snap.connectionState == ConnectionState.waiting) {
              return const Deferred();
            } else {
              return const Setup();
            }
          },
        ));
  }
}
