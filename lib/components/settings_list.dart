import 'package:allo/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsListHeader extends HookWidget {
  SettingsListHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7, left: 10, top: 7),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

enum RadiusType { TOP, BOTTOM, BOTH }

class SettingsListTile extends HookWidget {
  SettingsListTile(
      {required this.title,
      this.onTap,
      required this.type,
      this.leading,
      this.trailing,
      this.color,
      this.center});
  final String title;
  final Function? onTap;
  final RadiusType type;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final bool? center;
  @override
  Widget build(BuildContext context) {
    final colors = useProvider(Repositories.colors);
    return ListTile(
      title: center != null
          ? center!
              ? Center(child: Text(title))
              : Text(title)
          : Text(title),
      tileColor: color ?? colors.tileColor,
      leading: leading,
      trailing: trailing,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: (type == RadiusType.TOP || type == RadiusType.BOTH)
              ? Radius.circular(20)
              : Radius.zero,
          topRight: (type == RadiusType.TOP || type == RadiusType.BOTH)
              ? Radius.circular(20)
              : Radius.zero,
          bottomLeft: (type == RadiusType.BOTTOM || type == RadiusType.BOTH)
              ? Radius.circular(20)
              : Radius.zero,
          bottomRight: (type == RadiusType.BOTTOM || type == RadiusType.BOTH)
              ? Radius.circular(20)
              : Radius.zero,
        ),
      ),
      onTap: () async => onTap != null ? onTap!() : null,
    );
  }
}
