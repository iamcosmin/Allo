import 'package:allo/logic/authentication.dart';
import 'package:allo/logic/chat/chat.dart';
import 'package:allo/logic/navigation.dart';

class Core {
  static final Authentication auth = Authentication();
  static final Navigation navigation = Navigation();
  static Chat chat(chatId) => Chat(chatId: chatId);
}
