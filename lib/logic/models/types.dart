enum MessageType {
  text('text'),
  image('image'),
  unsupported('unsupported');

  const MessageType(this.type);
  final String type;

  @override
  String toString() => type;
}

MessageType getMessageType(String type) {
  if (type == 'text') {
    return MessageType.text;
  } else if (type == 'image') {
    return MessageType.image;
  } else {
    return MessageType.unsupported;
  }
}

String getStringMessageType(MessageType type) {
  if (type == MessageType.text) {
    return 'text';
  } else if (type == MessageType.image) {
    return 'image';
  } else {
    throw Exception();
  }
}

enum ChatType { private, group }
