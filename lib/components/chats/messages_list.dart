import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef MessageListBuilder = Widget Function(BuildContext context);

class MessageList extends HookConsumerWidget {
  MessageList({Key? key, required this.chatId, required this.builder})
      : super(key: key);
  final String chatId;
  final MessageListBuilder builder;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
