import 'package:allo/logic/authentication.dart';
import 'package:allo/logic/chat/chat.dart';
import 'package:allo/logic/navigation.dart';
import 'package:allo/logic/notifications.dart';
import 'package:flutter/material.dart';

class Core {
  static final Authentication auth = Authentication();
  static final Navigation navigation = Navigation();
  static final Notifications notifications = Notifications();
  static Chat chat(chatId) => Chat(chatId: chatId);
  static final Stub stub = Stub();
}

class Stub {
  void showInfoBar({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(icon),
            const Padding(padding: EdgeInsets.only(left: 20)),
            Text(text),
          ],
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
