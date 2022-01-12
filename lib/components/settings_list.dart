import 'package:allo/logic/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsListHeader extends HookWidget {
  const SettingsListHeader(this.text, {Key? key}) : super(key: key);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, left: 10, top: 7),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

// ignore: constant_identifier_names
enum RadiusType { TOP, BOTTOM, BOTH }

class SettingsListTile extends HookConsumerWidget {
  const SettingsListTile(
      {required this.title,
      this.onTap,
      required this.type,
      this.leading,
      this.trailing,
      this.color,
      this.center,
      Key? key})
      : super(key: key);
  final String title;
  final Function? onTap;
  final RadiusType type;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final bool? center;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorsProvider);
    return ListTile(
      title: center != null
          ? center!
              ? Center(child: Text(title))
              : Text(title)
          : Text(title),
      tileColor: color ?? colors.tileColor,
      leading: leading,
      trailing: trailing,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      onTap: () async => onTap != null ? onTap!() : null,
    );
  }
}
