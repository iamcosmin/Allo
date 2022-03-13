import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NAppBar extends HookConsumerWidget implements PreferredSizeWidget {
  const NAppBar({
    Key? key,
    this.title,
    this.actions,
    this.elevation,
    this.toolbarHeight,
  }) : super(key: key);
  final Widget? title;
  final List<Widget>? actions;
  final double? elevation;
  final double? toolbarHeight;
  @override
  Size get preferredSize => toolbarHeight != null
      ? Size.fromHeight(toolbarHeight!)
      : AppBar().preferredSize;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: title,
      actions: actions,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(100),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: Theme.of(context).colorScheme.surface.withAlpha(100),
          ),
        ),
      ),
    );
  }
}
