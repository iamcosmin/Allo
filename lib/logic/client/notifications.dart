import 'dart:async';
import 'dart:math';

import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';
import '../../interface/home/chat/chat.dart';
import '../core.dart';

/// Returns the title of the conversation (distinguish from group and private)
String _title({
  required String? type,
  required String chatName,
  required String senderName,
}) {
  if (getChatTypeFromString(type ?? 'group') == ChatType.private) {
    return senderName;
  } else {
    return chatName;
  }
}

/// Creates an unique ID for notifications, requires the max value.
int _createUniqueID(int maxValue) {
  final random = Random();
  return random.nextInt(maxValue);
}

class Notifications {
  const Notifications();

  /// Sets up all notification channels.
  ///! This method does not handle setting listeners anymore, as
  ///! the setListeners method should be only used in the first render
  ///! of the widget.
  Future setupNotifications() async {
    final notifications = AwesomeNotifications();
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
  }

  Future<void> ensureListenersActive() async {
    final notifications = AwesomeNotifications();
    await notifications.setListeners(
      onActionReceivedMethod: _NotificationController.onActionReceivedMethod,
    );
  }
}

/// This function sets up the notification system.
/// TODO (iamcosmin): Refactor this function, this is very cluttered.
/// TODO: Probably with a data class.
Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final String? uid = message.data['uid'];
  final String? senderName = message.data['senderName'];
  final String? text = message.data['text'];
  final String? profilePicture = message.data['profilePicture'];
  final String? sentPicture = message.data['photo'];
  final String? chatId = message.data['toChat'];
  final String smallNotificationText =
      getChatTypeFromString(message.data['type']) == ChatType.group
          ? message.data['chatName']
          : 'Privat';
  final notificationLayout =
      getChatTypeFromString(message.data['type']) == ChatType.group
          ? NotificationLayout.MessagingGroup
          : NotificationLayout.Messaging;
  // ignore: omit_local_variable_types
  final Map<String, String> suplimentaryInfo = {
    'profilePicture': profilePicture ?? '',
    'chatId': chatId ?? '',
    'chatName': _title(
      type: message.data['type'],
      chatName: message.data['chatName'],
      senderName: message.data['senderName'],
    ),
    'chatType': message.data['type'] ?? 'group',
    'uid': uid ?? 'no-uid'
  };
  if (uid != Core.auth.user.uid) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _createUniqueID(AwesomeNotifications.maxID),
        title: senderName,
        body: sentPicture != null ? 'Imagine' : text,
        channelKey: 'conversations',
        roundedLargeIcon: true,
        largeIcon: profilePicture,
        notificationLayout: NotificationLayout.MessagingGroup,
        category: NotificationCategory.Message,
        roundedBigPicture: true,
        bigPicture: sentPicture,
        groupKey: chatId,
        summary: smallNotificationText,
        payload: suplimentaryInfo,
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

    final notificationLayout =
        getChatTypeFromString(payload['chatType']!) == ChatType.group
            ? NotificationLayout.MessagingGroup
            : NotificationLayout.Messaging;
    final smallNotificationText =
        getChatTypeFromString(payload['chatType']!) == ChatType.group
            ? payload['chatName']!
            : 'Privat';
    if (action.actionType == ActionType.SilentBackgroundAction &&
        action.buttonKeyInput.isNotEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await Core.chat(payload['chatId']).messages.sendTextMessage(
            text: action.buttonKeyInput,
            chatName: payload['chatName']!,
            chatType: payload['chatType']!,
          );
      // ignore: omit_local_variable_types
      final Map<String, String?> suplimentaryInfo = {
        'chatId': payload['chatId'] ?? '',
        'chatName': payload['chatName'],
        'chatType': payload['chatType'],
      };
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: _createUniqueID(AwesomeNotifications.maxID),
          title: 'Eu',
          body: action.buttonKeyInput,
          channelKey: 'conversations',
          roundedLargeIcon: true,
          notificationLayout: notificationLayout,
          category: NotificationCategory.Message,
          roundedBigPicture: true,
          groupKey: payload['chatId'],
          summary: smallNotificationText,
          payload: suplimentaryInfo,
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

  static Chat _getChat(Map<String, String?> payload) {
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
