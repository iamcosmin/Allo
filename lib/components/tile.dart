import 'package:allo/components/empty.dart';
import 'package:allo/components/space.dart';
import 'package:allo/components/switch.dart';
import 'package:flutter/material.dart';

class SwitchTile extends StatelessWidget {
  const SwitchTile({
    required this.title,
    required this.value,
    this.subtitle,
    this.onChanged,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(context) {
    return Tile(
      title: title,
      subtitle: subtitle,
      trailing: AdaptiveSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.disabled = false,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool disabled;
  final void Function()? onTap;

  @override
  Widget build(context) {
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: disabled ? 0.7 : 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                IconTheme(
                  data: const IconThemeData(size: 26),
                  child: leading ?? const Empty(),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 20,
                      left: leading != null ? 20 : 0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 19,
                                      fontFamily: 'Display',
                                      fontWeight: FontWeight.normal,
                                    ),
                            child: title,
                          ),
                          if (subtitle != null) ...[
                            const Space(0.5),
                            DefaultTextStyle(
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                              child: subtitle ?? Container(),
                            )
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      child: trailing ?? Container(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
