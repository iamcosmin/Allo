import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:allo/logic/client/theme/theme.dart';
import 'package:allo/logic/models/chat.dart';
import 'package:allo/logic/models/types.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../../interface/home/chat/chat.dart';
import '../core.dart';

/// Returns the title of the conversation (distinguish from group and private)
String _title({
  required String? type,
  required String chatName,
  required String senderName,
}) {
  if (ChatType.fromString(type ?? 'group') == ChatType.private) {
    return senderName;
  } else {
    return chatName;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final data = message.data;
  const version = 1;

  final remoteVersion = data['version'];

  if (version.toString() == remoteVersion.toString()) {
    debugPrint('Version is OK');
    final message = jsonDecode(data['message']);

    final chat = message['chat'] as Map;
    final chatName = chat['name'];
    final chatId = chat['id'];
    final chatType = chat['type'];
    final chatPhotoURL = chat['photoURL'];

    final sender = message['sender'] as Map;
    final senderName = sender['name'];
    final senderId = sender['id'];
    final senderPhotoURL = sender['photoURL'];

    final content = message['content'] as Map;
    final contentType = content['type'];
    final contentText = content['text'];
    final contentPhotoURL = content['photoURL'];

    // If the user sent the message, why bother showing the notification to him?
    if (senderId != FirebaseAuth.instance.currentUser?.uid) {
      debugPrint('User OK');
      Future<String?> parsedPhotoURL(photoURL) async {
        if (photoURL != null) {
          final uri = Uri.parse(photoURL);

          if (uri.scheme == "http" || uri.scheme == "https") {
            return uri.toString();
          } else if (uri.scheme == "gs") {
            final propperURL = await FirebaseStorage.instance
                .refFromURL(uri.toString())
                .getDownloadURL();
            return propperURL;
          } else {
            // Scheme not currently supported.
          }
        }
        return null;
      }

      NotificationLayout notificationLayout() {
        final type = ChatType.fromString(chatType);
        switch (type) {
          case ChatType.private:
            return NotificationLayout.Messaging;
          case ChatType.group:
            return NotificationLayout.MessagingGroup;
          case ChatType.unsupported:
            return NotificationLayout.Default;
        }
      }

      String notificationBody() {
        final type = MessageType.fromString(contentType);
        switch (type) {
          case MessageType.text:
            return contentText;
          case MessageType.image:
            return contentText ?? 'Image';
          case MessageType.unsupported:
            return 'Unsupported Message.';
        }
      }

      String notificationSummary() {
        final type = ChatType.fromString(chatType);
        switch (type) {
          case ChatType.private:
            return '';
          case ChatType.group:
            return chatName;
          case ChatType.unsupported:
            return '';
        }
      }

      final payload = <String, String?>{};

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          //
          id: Random().nextInt(AwesomeNotifications.maxID),
          channelKey: 'chats',
          //
          category: NotificationCategory.Message,
          notificationLayout: notificationLayout(),
          //
          largeIcon: await parsedPhotoURL(senderPhotoURL),
          roundedLargeIcon: true,
          summary: notificationSummary(),
          title: senderName,
          body: notificationBody(),
          bigPicture: await parsedPhotoURL(contentPhotoURL),
          //
          groupKey: chatId,
          payload: payload,
          //
        ),
      );
    }
  } else {
    // Create failed notification
  }
}

Future<void> oldFirebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final String? uid = message.data['uid'];
  final String? senderName = message.data['senderName'];
  final String? text = message.data['text'];
  final String? profilePicture = message.data['profilePicture'];
  final String? sentPicture = message.data['photo'];
  final String? chatId = message.data['toChat'];
  final String smallNotificationText =
      ChatType.fromString(message.data['type']) == ChatType.group
          ? message.data['chatName']
          : '';
  final notificationLayout =
      ChatType.fromString(message.data['type']) == ChatType.group
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
  if (uid != Core.auth.user.userId) {
    // Decompile profile picture
    Future<Uri?> profilePictureUri() async {
      if (profilePicture != null) {
        final schema = Uri.parse(profilePicture);
        if (schema.scheme == 'http' || schema.scheme == 'https') {
          return schema;
        } else if (schema.scheme == 'gs') {
          return Uri.parse(
            await FirebaseStorage.instance
                .refFromURL(schema.toString())
                .getDownloadURL(),
          );
        }
      }
      return null;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(AwesomeNotifications.maxID),
        title: senderName,
        body: sentPicture != null ? 'Imagine' : text,
        channelKey: 'chats',
        roundedLargeIcon: true,
        largeIcon: (await profilePictureUri()).toString(),
        notificationLayout: notificationLayout,
        category: NotificationCategory.Message,
        // bigPicture: sentPicture,
        groupKey: chatId,
        // Summary is the chat name. Chat name should be null if the chat is private.
        summary: smallNotificationText,
        payload: suplimentaryInfo,
      ),
      actionButtons: [
        if (true == false) ...[
          NotificationActionButton(
            key: 'input',
            actionType: ActionType.SilentBackgroundAction,
            requireInputText: true,
            label: 'Reply',
          )
        ],
      ],
    );
  }
}

class Notifications {
  const Notifications();

  /// Sets up all notification channels.
  ///! This method does not handle setting listeners anymore, as
  ///! the setListeners method should be only used in the first render
  ///! of the widget.
  static Future setupNotifications() async {
    if (!kIsWeb) {
      await AwesomeNotifications().initialize(
        'resource://drawable/res_notification',
        [
          NotificationChannel(
            channelKey: 'chats',
            channelName: 'Chats',
            channelDescription: 'Chat notifications.',
            defaultColor: kDefaultBrandingColor,
            ledColor: kDefaultBrandingColor,
            playSound: true,
            importance: NotificationImportance.Max,
          )
        ],
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    }
    // Notifications are not available on Web.
  }

  static Future<void> ensureListenersActive() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _NotificationController.onActionReceivedMethod,
    );
  }
}

/// This function sets up the notification system.
/// TODO (iamcosmin): Refactor this function, this is very cluttered.
/// TODO: Probably with a data class.
class _NotificationController {
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    final payload = action.payload!;

    final notificationLayout =
        ChatType.fromString(payload['chatType']!) == ChatType.group
            ? NotificationLayout.MessagingGroup
            : NotificationLayout.Messaging;
    final smallNotificationText =
        ChatType.fromString(payload['chatType']!) == ChatType.group
            ? payload['chatName']!
            : 'Privat';
    if (action.actionType == ActionType.SilentBackgroundAction &&
        action.buttonKeyInput.isNotEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await Core.chats.chat(payload['chatId']).messages.sendTextMessage(
            text: action.buttonKeyInput,
            chatName: payload['chatName']!,
            chatType: ChatType.fromString(payload['chatType']!),
          );
      // ignore: omit_local_variable_types
      final Map<String, String?> suplimentaryInfo = {
        'chatId': payload['chatId'] ?? '',
        'chatName': payload['chatName'],
        'chatType': payload['chatType'],
      };
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(AwesomeNotifications.maxID),
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
      Navigation.forward(
        ChatScreen(
          chat: _getChat(action.payload!),
        ),
      );
    }
  }

  static Chat _getChat(Map<String, String?> payload) {
    final chatType = ChatType.fromString(payload['chatType'] ?? '???');
    if (chatType == ChatType.private) {
      return PrivateChat(
        name: payload['chatName'] ?? '???',
        userId: payload['uid'] ?? '???',
        id: payload['chatId'] ?? '???',
        memberUids: [],
      );
    } else if (chatType == ChatType.group) {
      return GroupChat(
        title: payload['chatName'] ?? '???',
        id: payload['chatId'] ?? '???',
        memberUids: [],
      );
    } else {
      throw Exception('This chatType is not defined.');
    }
  }
}
