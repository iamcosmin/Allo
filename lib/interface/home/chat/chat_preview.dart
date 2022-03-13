import 'package:allo/components/appbar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserPreviewPage extends HookConsumerWidget {
  const UserPreviewPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      appBar: NAppBar(
        title: Text('Soon.'),
      ),
    );
  }
}
