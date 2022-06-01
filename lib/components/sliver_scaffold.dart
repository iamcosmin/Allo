import 'package:allo/components/material3/app_bar.dart';
import 'package:allo/components/top_app_bar.dart';
import 'package:flutter/material.dart' hide SliverAppBar;

extension on SliverAppBar {}

@Deprecated('Please use SScaffold.' 'This will be deprecated very soon.')
class OldSliverScaffold extends StatelessWidget {
  const OldSliverScaffold({
    required this.appBar,
    required this.body,
    this.slivers,
    super.key,
  });
  final LargeTopAppBar appBar;
  final Widget body;
  final List<Widget>? slivers;

  @override
  Widget build(context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) {
          return [appBar];
        },
        body: body,
      ),
    );
  }
}

class SScaffold extends StatelessWidget {
  const SScaffold({
    required this.topAppBar,
    required this.slivers,
    this.refreshIndicator,
    super.key,
  });
  final TopAppBar topAppBar;
  final List<Widget> slivers;
  final RefreshIndicator? refreshIndicator;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: topAppBar,
          )
        ],
        body: Builder(
          builder: (context) {
            if (refreshIndicator != null) {
              return RefreshIndicator(
                onRefresh: refreshIndicator!.onRefresh,
                backgroundColor: refreshIndicator!.backgroundColor,
                color: refreshIndicator!.color,
                displacement: refreshIndicator!.displacement,
                child: CustomScrollView(
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                    ...slivers
                  ],
                ),
              );
            } else {
              return CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                      context,
                    ),
                  ),
                  ...slivers
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
