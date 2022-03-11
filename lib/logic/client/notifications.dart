import 'dart:async';
import 'dart:math';

import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../interface/home/chat/chat.dart';
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
  final notifications = AwesomeNotifications();
  final notificationController = _NotificationController();

  /// Sets up all notification channels.
  Future setupNotifications() async {
    await notifications.initialize(
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
    await notifications.setListeners(
      onActionReceivedMethod: _NotificationController.onActionReceivedMethod,
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
    'uid': _uid ?? 'no-uid'
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
      actionButtons: [
        NotificationActionButton(
          key: 'input',
          actionType: ActionType.SilentBackgroundAction,
          requireInputText: true,
          label: 'Reply',
        )
      ],
    );
  }
}

class _NotificationController {
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    final payload = action.payload!;
    final _notificationLayout =
        getChatTypeFromString(payload['chatType']!) == ChatType.group
            ? NotificationLayout.MessagingGroup
            : NotificationLayout.Messaging;
    final _smallNotificationText =
        getChatTypeFromString(payload['chatType']!) == ChatType.group
            ? payload['chatName']!
            : 'Privat';
    if (action.actionType == ActionType.SilentBackgroundAction &&
        action.buttonKeyInput.isNotEmpty) {
      //
      await Core.chat(payload['chatId']).messages.sendTextMessage(
          text: action.buttonKeyInput,
          chatName: payload['chatName']!,
          chatType: payload['chatType']!);
      // ignore: omit_local_variable_types
      final Map<String, String> _suplimentaryInfo = {
        'chatId': payload['chatId'] ?? '',
        'chatName': payload['chatName']!,
        'chatType': payload['chatType']!,
      };
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _createUniqueID(AwesomeNotifications.maxID),
          title: 'Eu',
          body: action.buttonKeyInput,
          channelKey: 'conversations',
          roundedLargeIcon: true,
          notificationLayout: _notificationLayout,
          category: NotificationCategory.Message,
          roundedBigPicture: true,
          groupKey: payload['chatId'],
          summary: _smallNotificationText,
          payload: _suplimentaryInfo,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'input',
            actionType: ActionType.SilentBackgroundAction,
            requireInputText: true,
            label: 'Reply',
          )
        ],
      );
    } else {
      Core.navigation.push(
        route: ChatScreen(
          chat: _getChat(action.payload!),
        ),
      );
    }
  }

  static Chat _getChat(Map<String, String> payload) {
    final chatType = getChatTypeFromString(payload['chatType'] ?? '???');
    if (chatType == ChatType.private) {
      return PrivateChat(
        name: payload['chatName'] ?? '???',
        userId: payload['uid'] ?? '???',
        chatId: payload['chatId'] ?? '???',
      );
    } else if (chatType == ChatType.group) {
      return GroupChat(
        title: payload['chatName'] ?? '???',
        chatId: payload['chatId'] ?? '???',
      );
    } else {
      throw Exception('This chatType is not defined.');
    }
  }
}
