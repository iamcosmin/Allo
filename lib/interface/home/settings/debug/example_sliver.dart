import 'package:allo/components/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExampleSliver extends HookConsumerWidget {
  const ExampleSliver({super.key});

  @override
  Widget build(context, ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const LargeTopAppBar(
            title: Text('Acasa'),
          ),
          // Just some content big enough to have something to scroll.
          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(index.toString()),
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