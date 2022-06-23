import 'chat.dart';
import 'messages.dart';

enum MessageType {
  text(),
  image(),
  unsupported();

  factory MessageType.fromString(String from) {
    return MessageType.values.firstWhere((element) => element.name == from);
  }

  factory MessageType.fromMessage(Message from) {
    switch (from.runtimeType) {
      case TextMessage:
        return MessageType.text;
      case ImageMessage:
        return MessageType.image;
      default:
        return MessageType.unsupported;
    }
  }
}

enum ChatType {
  private,
  group,
  unsupported;

  factory ChatType.fromString(String from) {
    return ChatType.values.firstWhere((element) => element.name == from);
  }

  factory ChatType.fromChat(Chat from) {
    switch (from.runtimeType) {
      case PrivateChat:
        return ChatType.private;
      case GroupChat:
        return ChatType.group;
      default:
        return ChatType.unsupported;
    }
  }
}
