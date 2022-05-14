import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef MessageListBuilder = Widget Function(BuildContext context);

class MessageList extends HookConsumerWidget {
  MessageList({
    required this.chatId,
    required this.builder,
    super.key,
  });
  final String chatId;
  final MessageListBuilder builder;
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}
