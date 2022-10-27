import 'package:allo/components/slivers/sliver_scaffold.dart';
import 'package:allo/components/slivers/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExampleSliver extends HookConsumerWidget {
  const ExampleSliver({super.key});

  @override
  Widget build(context, ref) {
    return Scaffold(
      body: SScaffold(
        topAppBar: const LargeTopAppBar(
          title: Text('Acasa'),
        ),
        slivers: <Widget>[
          // Just some content big enough to have something to scroll.
          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ListTile(
                    title: Text(index.toString()),
                  );
                },
                childCount: 50,
              ),
            ),
          )
        ],
      ),
    );
  }
}
