import 'package:flutter/material.dart';

enum _TopAppBarType { medium, large }

abstract class TopAppBar extends StatelessWidget {
  const TopAppBar({
    required this.title,
    required this.collapsedHeight,
    required this.expandedHeight,
    super.key,
  });

  final Widget title;
  final double collapsedHeight;
  final double expandedHeight;

  @override
  SliverAppBar build(BuildContext context);
}

extension on BuildContext {
  T? inherit<T extends InheritedWidget>() {
    return dependOnInheritedWidgetOfExactType<T>();
  }
}

class SmallTopAppBar extends TopAppBar {
  const SmallTopAppBar({
    required super.title,
    super.collapsedHeight = 64,
    super.expandedHeight = 64,
    this.leading,
    this.actions,
    super.key,
  });

  final Widget? leading;
  final List<Widget>? actions;

  @override
  SliverAppBar build(BuildContext context) {
    return SliverAppBar(
      toolbarHeight: 64,
      pinned: true,
      leading: leading,
      title: title,
      actions: actions,
    );
  }
}

class MediumTopAppBar extends TopAppBar {
  const MediumTopAppBar({
    required super.title,
    super.collapsedHeight = _MediumScrollUnderFlexibleConfig.collapsedHeight,
    super.expandedHeight = _MediumScrollUnderFlexibleConfig.expandedHeight,
    this.leading,
    super.key,
  });
  final Widget? leading;

  @override
  SliverAppBar build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      pinned: true,
      leading: leading,
      flexibleSpace: _M3FlexibleSpaceBar(
        title: title,
        hasLeading: leading != null || Navigator.canPop(context),
        type: _TopAppBarType.medium,
      ),
    );
  }
}

class LargeTopAppBar extends TopAppBar {
  const LargeTopAppBar({
    required super.title,
    super.collapsedHeight = _LargeScrollUnderFlexibleConfig.collapsedHeight,
    super.expandedHeight = _LargeScrollUnderFlexibleConfig.expandedHeight,
    this.leading,
    super.key,
  });
  final Widget? leading;
  @override
  SliverAppBar build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      pinned: true,
      leading: leading,
      flexibleSpace: _M3FlexibleSpaceBar(
        title: title,
        type: _TopAppBarType.large,
        hasLeading: leading != null || Navigator.canPop(context),
      ),
    );
  }
}

class _M3FlexibleSpaceBar extends StatelessWidget {
  /// [_M3FlexibleSpaceBar] is a [Widget] specially created to deal with the inconsistencies
  /// that the Flutter team has yet to fix between the native LargeTopAppBar and MediumTopAppBar
  ///  and their solutions, [SliverAppBar.large] and [SliverAppBar.medium].
  ///
  /// More exactly, this is the base which [MediumTopAppBar] and [LargeTopAppBar] use for their
  /// collapsing ability.
  ///
  /// Here, we worked very hard to accomplish the Jetpack Compose look, as we thought Google had
  /// worked harder on this side than Material Components.
  ///
  /// The behavior should be the following:
  /// * when the bar collapses, the shift in opacity between the large title, the small title and
  /// the color of the [TopAppBar] should be gradual, as the user scrolls, rather than abrupt,
  /// with an animation at a fixed point (the approach that the Flutter team took)
  /// * instead of showing the elevation changes when scrolling only if the content scrolls behind
  /// the content (which is very problematic, using a [NestedScrollView] would require passing
  /// the [forceElevated] property from the [NestedScrollView] to the [SliverAppBar]), we took a
  /// different approach: using the new [ElevationOverlay.applySurfaceTint], we applied the color
  /// based on the scroll position using a specially crafted formula that ensures we do not use
  /// [Opacity], but rather link the elevation with the scroll position. This ensures a smooth
  /// transition right from the start, without needing to pass down redundant arguments; when the
  /// bar is completely collapsed, the elevation behaves like a scrolledUnder event.
  /// * instead of polluting the current [SliverAppBar], we created new widgets that are more
  /// cleaner ([LargeTopAppBar] and [MediumTopAppBar]).
  const _M3FlexibleSpaceBar({
    required this.title,
    required this.type,
    required this.hasLeading,
    // ignore: unused_element
    super.key,
  });
  final bool hasLeading;
  final Widget title;
  final _TopAppBarType type;
  @override
  Widget build(context) {
    final settings = context.inherit<FlexibleSpaceBarSettings>() ??
        (throw Exception(
          "The TopAppBar widget you're using is a sliver. To use is, implement it in a CustomScrollView or NestedScrollView.",
        ));

    //? [CONFIGURATION]
    // This widget is helping us style the UI elements, while also keeping everything down to one widget.
    _ScrollUnderFlexibleConfig config;
    switch (type) {
      case _TopAppBarType.medium:
        config = _MediumScrollUnderFlexibleConfig(context);
        break;
      case _TopAppBarType.large:
        config = _LargeScrollUnderFlexibleConfig(context);
    }
    // This is a variable for the token defaults.
    final tokens = _TokenDefaultsM3(context);

    //? [VALUES]
    // [systemPadding] is a collection of EdgeInsets that actually show the system insets, such as
    // status bar padding, otherwise the content may go under the status bar.
    // The next defined heights are used for relations to be implemented in the collapsing process.
    final systemPadding = MediaQuery.of(context).padding;

    //? [RELATIONS]
    // Explanation of the behavior flexible space bar is doing here.
    // In native behavior, the extendable TopAppBar behaves like this:
    // * Opacity of the large title is 1.0 when it is fully expanded and 0.0 when the title goes under the collapsed AppBar.
    // * Opacity of the small title is 0.0 when it is fully expanded and 1.0 when the big title goes under the collapsed AppBar.
    // Every formula present here MUST be relative, not fixed, so that at any extent, the extendable
    // TopAppBar behaves correctly.

    // Explanation of the formula. The substracting minExtent from currentExtent gets us the
    // current extended area, meanwhile substracting minExtent from maxExtent minExtent gets us
    // the total extendeable area, thus if the title is fully expanded, the result will be 1.0
    // (the current extended area is equal to the maximum extendeable area), while if
    // the space is at its minimum (0), of course divinding 0 will get you 0.
    final expandedTitleOpacity = (settings.currentExtent - settings.minExtent) /
        (settings.maxExtent - settings.minExtent);
    // Explanation of the formula. This formula is the complete opposite of the formula
    // above. With trial and error, I discovered that, if inversing minExtent and maxExtent
    // substraction, we will get an inversed operation. Adding 1 is just so the operation
    // is positive.
    final collapsedTitleOpacity =
        ((settings.currentExtent - settings.minExtent) /
                (settings.minExtent - settings.maxExtent)) +
            1;
    // Explanation of the formula. In the native behavior, while scrolling, the collapsed title
    // as well as the backgroundColor of the collapsed space have the same gradual opacity changes.
    // So, I have written the elevationLevel in a way that it's completely linked to the collapsed
    // title changes.
    final topAppBarElevationLevel =
        collapsedTitleOpacity * tokens.scrolledUnderElevation!;

    //? [THEME]
    final colorScheme = Theme.of(context).colorScheme;
    final surfaceTint = colorScheme.surfaceTint;
    final surface = colorScheme.surface;
    // This is the backgroundColor of the TopAppBar, using the special formula which ensures
    // that the color intensity will change on scroll.
    final backgroundColor = ElevationOverlay.applySurfaceTint(
      surface,
      surfaceTint,
      topAppBarElevationLevel,
    );
    // The forever dispute of centering the title.
    // Apple platforms have centered title, meanwhile other platforms have it to the left or right.
    //? This only affects the small title, as the large title seems to have the same behavior on all
    //? platforms.
    bool centerTitle() {
      final platform = Theme.of(context).platform;
      switch (platform) {
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
          return false;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return true;
      }
    }

    // A note to all future contributions on the following code: as the opacity values change
    // many times a second, we have to make the following widgets more performant, without
    // any bloat. So, please do not simply use [Container], but rather use nested Widgets
    // that do the [Container] job; I don't think that you are going to use all the Container's
    // features at once. This may seem very stupid, but in my tests, performance is increased when
    // we are using separate widgets based on what we want to use.
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          // ExtendedTitle configuration.
          Padding(
            padding: config.expandedTitlePadding ??
                (throw Exception('The provided expandedTitlePadding is null.')),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Opacity(
                opacity: expandedTitleOpacity,
                child: DefaultTextStyle(
                  style: config.expandedTextStyle!,
                  child: title,
                ),
              ),
            ),
          ),
          // CollapsedTitle configuration.
          SizedBox.fromSize(
            size: Size.fromHeight(settings.minExtent),
            child: ColoredBox(
              color: backgroundColor,
              // NOTE: settings.minExtent includes both toolbarHeight and the top system inset.
              // This is to ensure that the TopAppBar backgroundColor will be applied to the status bar.
              child: Align(
                alignment:
                    centerTitle() ? Alignment.center : Alignment.centerLeft,
                child: Opacity(
                  opacity: collapsedTitleOpacity,
                  child: Padding(
                    padding: centerTitle()
                        ? config.collapsedCenteredTitlePadding!
                            .add(EdgeInsets.only(top: systemPadding.top))
                        : config.collapsedTitlePadding!
                            .add(EdgeInsets.only(top: systemPadding.top)),
                    child: DefaultTextStyle(
                      style: config.collapsedTextStyle!,
                      child: title,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//! BEGIN GENERATED CONFIGURATIONS

// The following configurations have been copied from the official Flutter repo.
// We want to exactly match the M3 tokens, while also making our own behavior work.

mixin _ScrollUnderFlexibleConfig {
  TextStyle? get collapsedTextStyle;
  TextStyle? get expandedTextStyle;
  EdgeInsetsGeometry? get collapsedTitlePadding;
  EdgeInsetsGeometry? get collapsedCenteredTitlePadding;
  EdgeInsetsGeometry? get expandedTitlePadding;
}

// BEGIN GENERATED TOKEN PROPERTIES

// Generated code to the end of this file. Do not edit by hand.
// These defaults are generated from the Material Design Token
// database by the script dev/tools/gen_defaults/bin/gen_defaults.dart.

// Generated version v0_98
class _TokenDefaultsM3 extends AppBarTheme {
  _TokenDefaultsM3(this.context)
      : super(
          elevation: 0.0,
          scrolledUnderElevation: 3.0,
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          toolbarHeight: 64.0,
        );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  Color? get foregroundColor => _colors.onSurface;

  @override
  Color? get surfaceTintColor => _colors.surfaceTint;

  @override
  IconThemeData? get iconTheme => IconThemeData(
        color: _colors.onSurface,
        size: 24.0,
      );

  @override
  IconThemeData? get actionsIconTheme => IconThemeData(
        color: _colors.onSurfaceVariant,
        size: 24.0,
      );

  @override
  TextStyle? get toolbarTextStyle => _textTheme.bodyText2;

  @override
  TextStyle? get titleTextStyle => _textTheme.titleLarge;
}

// Variant configuration
class _MediumScrollUnderFlexibleConfig with _ScrollUnderFlexibleConfig {
  _MediumScrollUnderFlexibleConfig(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  static const double collapsedHeight = 64.0;
  static const double expandedHeight = 112.0;

  @override
  TextStyle? get collapsedTextStyle =>
      _textTheme.titleLarge?.apply(color: _colors.onSurface);

  @override
  TextStyle? get expandedTextStyle =>
      _textTheme.headlineSmall?.apply(color: _colors.onSurface);

  @override
  EdgeInsetsGeometry? get collapsedTitlePadding =>
      const EdgeInsetsDirectional.fromSTEB(48, 0, 16, 0);

  @override
  EdgeInsetsGeometry? get collapsedCenteredTitlePadding =>
      const EdgeInsets.fromLTRB(16, 0, 16, 0);

  @override
  EdgeInsetsGeometry? get expandedTitlePadding =>
      const EdgeInsets.fromLTRB(16, 0, 16, 20);
}

class _LargeScrollUnderFlexibleConfig with _ScrollUnderFlexibleConfig {
  _LargeScrollUnderFlexibleConfig(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  // ignore: unused_field
  static const double collapsedHeight = 64.0;
  // ignore: unused_field
  static const double expandedHeight = 152.0;

  @override
  TextStyle? get collapsedTextStyle =>
      _textTheme.titleLarge?.apply(color: _colors.onSurface);

  @override
  TextStyle? get expandedTextStyle =>
      _textTheme.headlineMedium?.apply(color: _colors.onSurface);

  @override
  EdgeInsetsGeometry? get collapsedTitlePadding =>
      const EdgeInsetsDirectional.fromSTEB(48, 0, 16, 0);

  @override
  EdgeInsetsGeometry? get collapsedCenteredTitlePadding =>
      const EdgeInsets.fromLTRB(16, 0, 16, 0);

  @override
  EdgeInsetsGeometry? get expandedTitlePadding =>
      const EdgeInsets.fromLTRB(16, 0, 16, 28);
}

// END GENERATED TOKEN PROPERTIES
