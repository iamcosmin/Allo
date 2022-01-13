import 'dart:math';

import 'package:allo/logic/types.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'core.dart';

/// Returns the title of the conversation (distinguish from group and private)
String _title(
    {required String? type,
    required String chatName,
    required String senderName}) {
  if ((type ?? 'group') == ChatType.private) {
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
  final _uid = message.data['uid'];
  final _senderName = message.data['senderName'];
  final _text = message.data['text'];
  String? _profilePicture = message.data['profilePicture'];
  final _chatId = message.data['toChat'];
  final _smallNotificationText = message.data['type'] == ChatType.group
      ? message.data['chatName']
      : 'Privat';
  // ignore: omit_local_variable_types
  final Map<String, String> _suplimentaryInfo = {
    'profilePicture': _profilePicture ?? '',
    'chatId': _chatId,
    'chatName': _title(
        type: message.data['type'],
        chatName: message.data['chatName'],
        senderName: message.data['senderName']),
    'chatType': message.data['type'] ?? ChatType.group,
  };
  if (_uid != Core.auth.user.uid) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _createUniqueID(AwesomeNotifications.maxID),
        title: _senderName,
        body: _text,
        channelKey: 'conversations',
        roundedLargeIcon: true,
        largeIcon: _profilePicture,
        notificationLayout: NotificationLayout.Messaging,
        category: NotificationCategory.Message,
        groupKey: _chatId,
        summary: _smallNotificationText,
        payload: _suplimentaryInfo,
      ),
    );
  }
}
