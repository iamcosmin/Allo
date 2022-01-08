import 'dart:math';

import 'package:allo/components/deferred.dart';
import 'package:allo/interface/login/main_setup.dart';
import 'package:allo/repositories/preferences_repository.dart';
import 'package:allo/repositories/repositories.dart';
import 'package:allo/repositories/themes.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'interface/home/stack_navigator.dart';

int createUniqueID(int maxValue) {
  var random = Random();
  return random.nextInt(maxValue);
}

Future _onBackgroundMessage(RemoteMessage message) async {
  String title(
      {required String? type,
      required String chatName,
      required String senderName}) {
    if ((type ?? 'group') == ChatType.private) {
      return senderName;
    } else {
      return chatName;
    }
  }

  String body(
      {required String? type,
      required String senderName,
      required String text}) {
    if ((type ?? 'group') == ChatType.private) {
      return message.data['text'];
    } else {
      return message.data['senderName'] + ': ' + message.data['text'];
    }
  }

  await Firebase.initializeApp();
  if (message.data['uid'] != FirebaseAuth.instance.currentUser!.uid) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: createUniqueID(AwesomeNotifications.maxID),
          title: message.data['type'] == ChatType.group
              ? message.data['senderName']
              : null,
          body: message.data['text'],
          channelKey: 'conversations',
          notificationLayout: NotificationLayout.Messaging,
          category: NotificationCategory.Message,
          groupKey: message.data['toChat'],
          summary: message.data['type'] == ChatType.group
              ? message.data['chatName']
              : message.data['senderName'],
          payload: {
            'chatId': message.data['toChat'],
            'chatName': title(
                type: message.data['type'],
                chatName: message.data['chatName'],
                senderName: message.data['senderName']),
            'chatType': message.data['type'] ?? ChatType.group,
          }),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

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

  // Future<void> performUpdate(context) async {
  //   await InAppUpdate.checkForUpdate().then((value) async {
  //     if (value.updateAvailability == UpdateAvailability.updateAvailable) {
  //       await InAppUpdate.startFlexibleUpdate().then(
  //         (value) => ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             duration: const Duration(hours: 5),
  //             behavior: SnackBarBehavior.floating,
  //             content: const Text('Actualizarea este pregătită.'),
  //             action: SnackBarAction(
  //               label: 'Instalează',
  //               onPressed: () async {
  //                 await InAppUpdate.completeFlexibleUpdate();
  //               },
  //             ),
  //           ),
  //         ),
  //       );
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      if (!kIsWeb) {
        // performUpdate(context);
      }
    }, []);

    final darkState = useProvider(darkMode);
    return MaterialApp(
      title: 'Allo',
      scrollBehavior: const MaterialScrollBehavior(
          androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
      themeMode: darkState ? ThemeMode.dark : ThemeMode.light,
      theme: lightTheme,
      darkTheme: darkTheme,
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
      ),
    );
  }
}
