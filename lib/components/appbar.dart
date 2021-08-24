import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NavBar extends HookWidget implements PreferredSizeWidget {
  NavBar(
      {this.title,
      this.flexibleSpace,
      this.toolbarHeight,
      this.backgroundColor,
      this.leading,
      this.centerTitle});
  final Widget? title;
  final Widget? flexibleSpace;
  final double? toolbarHeight;
  final Color? backgroundColor;
  final Widget? leading;
  final bool? centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      flexibleSpace: flexibleSpace,
      toolbarHeight: toolbarHeight,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle ?? false,
      leading: leading ??
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(FluentIcons.arrow_left_16_regular)),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
}
