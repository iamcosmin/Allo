import 'package:flutter/material.dart';

/// [SliverScroll] is a simple wrapper for less boilerplate in a sliver.
/// Instead of returning a [SliverList], then passing the [SliverChildListDelegate],
/// you can direcly specify this.
/// The [children] parameter takes a [RenderBox].
class SliverScroll extends StatelessWidget {
  /// [SliverScroll] is a simple wrapper for less boilerplate in a sliver.
  /// Instead of returning a [SliverList], then passing the [SliverChildListDelegate],
  /// you can direcly specify this.
  /// The [children] parameter takes a [RenderBox].
  const SliverScroll({
    required this.children,
    super.key,
  });
  final List<Widget> children;

  @override
  Widget build(context) {
    return SliverList(
      delegate: SliverChildListDelegate(children),
    );
  }
}
