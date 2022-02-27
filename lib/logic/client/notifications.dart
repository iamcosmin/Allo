import 'dart:async';
import 'dart:math';

import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../interface/home/chat/chat.dart';
import '../../main.dart';
import '../core.dart';

/// Returns the title of the conversation (distinguish from group and private)
String _title(
    {required String? type,
    required String chatName,
    required String senderName}) {
  if (getChatTypeFromString((type ?? 'group')) == ChatType.private) {
    return senderName;
  } else {
    return chatName;
  }
}

/// Creates an unique ID for notifications, requires the max value.
int _createUniqueID(int maxValue) {
  var random = Random();
  return random.nextInt(maxValue);
}

class Notifications {
  /// Sets up all notification channels.
  Future setupNotifications() async {
    await AwesomeNotifications().initialize(
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
          channelShowBadge: true,
          criticalAlerts: false,
          defaultPrivacy: NotificationPrivacy.Private,
        )
      ],
    );
  }
}

/// This function sets up the notification system.
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  String? _uid = message.data['uid'];
  String? _senderName = message.data['senderName'];
  String? _text = message.data['text'];
  String? _profilePicture = message.data['profilePicture'];
  String? _sentPicture = message.data['photo'];
  String? _chatId = message.data['toChat'];
  String _smallNotificationText =
      getChatTypeFromString(message.data['type']) == ChatType.group
          ? message.data['chatName']
          : 'Privat';
  final _notificationLayout =
      getChatTypeFromString(message.data['type']) == ChatType.group
          ? NotificationLayout.MessagingGroup
          : NotificationLayout.Messaging;
  // ignore: omit_local_variable_types
  final Map<String, String> _suplimentaryInfo = {
    'profilePicture': _profilePicture ?? '',
    'chatId': _chatId ?? '',
    'chatName': _title(
        type: message.data['type'],
        chatName: message.data['chatName'],
        senderName: message.data['senderName']),
    'chatType': message.data['type'] ?? 'group',
  };
  if (_uid != Core.auth.user.uid) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _createUniqueID(AwesomeNotifications.maxID),
        title: _senderName,
        body: _sentPicture != null ? 'Imagine' : _text,
        channelKey: 'conversations',
        roundedLargeIcon: true,
        largeIcon: _profilePicture,
        notificationLayout: _notificationLayout,
        category: NotificationCategory.Message,
        roundedBigPicture: true,
        bigPicture: _sentPicture,
        groupKey: _chatId,
        summary: _smallNotificationText,
        payload: _suplimentaryInfo,
      ),
    );
  }
}

void useNotificationListener(BuildContext context) {
  return use(_NotificationListenerHook(context));
}

class _NotificationListenerHook extends Hook<void> {
  const _NotificationListenerHook(this.context);
  final BuildContext context;
  @override
  _NotificationListenerHookState createState() =>
      _NotificationListenerHookState();
}

class _NotificationListenerHookState
    extends HookState<void, _NotificationListenerHook> {
  @override
  void build(BuildContext context) {}

  @override
  void initHook() {
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
    super.initHook();
  }

  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    super.dispose();
  }
}
