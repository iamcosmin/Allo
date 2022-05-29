import 'package:flutter/material.dart' hide SliverAppBar;

import 'material3/app_bar.dart';

const _kProprietaryMode = true;

class LargeTopAppBar extends StatelessWidget {
  const LargeTopAppBar({
    required this.title,
    this.leading,
    super.key,
  });
  final Widget title;
  final Widget? leading;
  @override
  Widget build(BuildContext context) {
    if (!_kProprietaryMode) {
      return SliverAppBar.large(
        title: title,
      );
    } else {
      return SliverAppBar(
        expandedHeight: 152,
        toolbarHeight: 64,
        pinned: true,
        leading: leading,
        flexibleSpace: _M3FlexibleSpaceBar(
          title: title,
          hasLeading: leading != null || Navigator.canPop(context),
        ),
      );
    }
  }
}

class _M3FlexibleSpaceBar extends StatelessWidget {
  const _M3FlexibleSpaceBar({
    required this.title,
    required this.hasLeading,
    // ignore: unused_element
    super.key,
  });
  final bool hasLeading;
  final Widget title;
  @override
  Widget build(context) {
    final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>() ??
        (throw Exception(
          "The TopAppBar widget you're using is a sliver. To use is, implement it in a CustomScrollView or NestedScrollView.",
        ));

    //? [VALUES]
    final systemPadding = MediaQuery.of(context).padding;
    // [expandedHeight] is the maximum height the space bar can take without the system insets,
    // typically the height of the extended TopAppBar.
    final expandedHeight = settings.maxExtent - systemPadding.top;
    // [toolbarHeight] is the minimum height the space bar can take without the system insets,
    // typically the height of the collapsed TopAppBar.
    final toolbarHeight = settings.minExtent - systemPadding.top;
    // [currentHeight] is the height that the space bar is currently taking without the system insets,
    // typically the current height of the TopAppBar (in between of expandedHeight and toolbarHeight).
    final currentHeight = settings.currentExtent - systemPadding.top;

    //? [RELATIONS]
    // Explanation of the behavior flexible space bar is doing here.
    // In native behavior, LargeTopAppBar behaves like this:
    // * Opacity of the large title is 1.0 when it is fully expanded and 0.0 when the title goes under the collapsed AppBar.
    // * Opacity of the small title is 0.0 when it is fully expanded and 1.0 when the big title goes under the collapsed AppBar.

    final expandedTitleOpacity = (currentHeight - 64) / toolbarHeight;
    final collapsedTitleOpacity = (expandedHeight / currentHeight) - 1;
    final topAppBarElevationLevel = collapsedTitleOpacity * 2;

    //? [THEME]
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceTint = colorScheme.surfaceTint;
    final surface = colorScheme.surface;
    final backgroundColor = ElevationOverlay.applySurfaceTint(
      surface,
      surfaceTint,
      topAppBarElevationLevel,
    );
    bool centerTitle() {
      final platform = Theme.of(context).platform;
      switch (platform) {
        case TargetPlatform.android:
          return false;
        case TargetPlatform.fuchsia:
          return false;
        case TargetPlatform.iOS:
          return true;
        case TargetPlatform.linux:
          return false;
        case TargetPlatform.macOS:
          return true;
        case TargetPlatform.windows:
          return false;
      }
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 28),
            alignment: Alignment.bottomLeft,
            child: Opacity(
              opacity: expandedTitleOpacity <= 1.0 ? expandedTitleOpacity : 1.0,
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.headlineMedium!.apply(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                child: title,
              ),
            ),
          ),
          Container(
            color: backgroundColor,
            height: settings.minExtent,
            alignment: centerTitle() ? Alignment.center : Alignment.centerLeft,
            child: Opacity(
              opacity: collapsedTitleOpacity <= 1.0
                  ? collapsedTitleOpacity >= 0
                      ? collapsedTitleOpacity
                      : 0.0
                  : 1.0,
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: centerTitle()
                      ? 0
                      : hasLeading
                          ? 40
                          : 5,
                ),
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleLarge!.apply(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                  child: title,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
