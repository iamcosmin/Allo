import 'package:allo/logic/authentication.dart';
import 'package:allo/logic/chat/chat.dart';
import 'package:allo/logic/navigation.dart';
import 'package:allo/logic/notifications.dart';

class Core {
  static final Authentication auth = Authentication();
  static final Navigation navigation = Navigation();
  static final Notifications notifications = Notifications();
  static Chat chat(chatId) => Chat(chatId: chatId);
  static final Stub stub = Stub();
}

class Stub {
  final loadChats = chatLoader;
}
