  import 'package:allo/components/slivers/top_app_bar.dart';
  import 'package:flutter/material.dart';
  import 'package:sliver_tools/sliver_tools.dart';
  import 'package:snap_scroll_physics/snap_scroll_physics.dart';

  const _kNewDesign = true;

  class SScaffold extends StatelessWidget {
    const SScaffold({
      required this.topAppBar,
      required this.slivers,
      this.reverseScroll = false,
      this.floatingActionButton,
      this.pinnedSlivers,
      this.refreshIndicator,
      super.key,
    });
    final TopAppBar topAppBar;
    final bool reverseScroll;
    final List<Widget> slivers;
    final List<Widget>? pinnedSlivers;
    final RefreshIndicator? refreshIndicator;
    final FloatingActionButton? floatingActionButton;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        floatingActionButton: floatingActionButton,
        body: NestedScrollView(
          physics: SnapScrollPhysics(
            snaps: [
              Snap.avoidZone(
                0,
                topAppBar.expandedHeight -
                    topAppBar.collapsedHeight -
                    MediaQuery.of(context).viewInsets.top,
              )
            ],
          ),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: MultiSliver(
                children: [
                  if (_kNewDesign) ...[
                    topAppBar
                  ] else ...[
                    SmallTopAppBar(
                      title: topAppBar is LargeTopAppBar
                          ? (topAppBar as LargeTopAppBar).title
                          : topAppBar is MediumTopAppBar
                              ? (topAppBar as MediumTopAppBar).title
                              : (topAppBar as SmallTopAppBar).title,
                    ),
                  ],
                  ...?pinnedSlivers
                ],
              ),
            ),
          ],
          body: SafeArea(
            top: false,
            child: Builder(
              builder: (context) {
                if (refreshIndicator != null) {
                  return RefreshIndicator(
                    onRefresh: refreshIndicator!.onRefresh,
                    backgroundColor: refreshIndicator!.backgroundColor,
                    color: refreshIndicator!.color,
                    displacement: topAppBar.collapsedHeight +
                        MediaQuery.of(context).viewPadding.top,
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
        ),
      );
    }
  }
