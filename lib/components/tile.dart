import 'package:allo/components/empty.dart';
import 'package:allo/components/space.dart';
import 'package:allo/components/switch.dart';
import 'package:allo/logic/client/extensions.dart';
import 'package:flutter/material.dart';

class SwitchTile extends StatelessWidget {
  const SwitchTile({
    required this.title,
    required this.value,
    this.leading,
    this.subtitle,
    this.onChanged,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(context) {
    return Tile(
      leading: leading,
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

  Duration get animationDuration => const Duration(milliseconds: 250);
  @override
  Widget build(context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: animationDuration,
        opacity: disabled ? 0.7 : 1.0,
        child: AnimatedContainer(
          duration: animationDuration,
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                    size: 30,
                    color: context.colorScheme.onSurface,
                  ),
                  child: leading != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: leading,
                        )
                      : const Empty(),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultTextStyle(
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontFamily: 'Display',
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                          child: title,
                        ),
                        DefaultTextStyle(
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          child: AnimatedSize(
                            duration: animationDuration,
                            child: Column(
                              children: [
                                if (subtitle != null) ...[
                                  const Space(0.5),
                                  subtitle!
                                ] else ...[
                                  const SizedBox(
                                    width: double.infinity,
                                  )
                                ]
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Space(
                  2.6,
                  direction: Direction.horizontal,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    child: trailing ?? Container(),
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
