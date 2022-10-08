import 'package:allo/components/material3/switch_own.dart';
import 'package:allo/components/space.dart';
import 'package:allo/logic/client/extensions.dart';
import 'package:allo/logic/client/theme/animations.dart';
import 'package:flutter/material.dart';

class SwitchTile extends StatelessWidget {
  const SwitchTile({
    required this.title,
    required this.value,
    this.leading,
    this.subtitle,
    this.onChanged,
    this.disabledIcon,
    this.enabledIcon,
    super.key,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final bool value;
  final IconData? disabledIcon;
  final IconData? enabledIcon;
  final void Function(bool)? onChanged;

  @override
  Widget build(context) {
    return Tile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged?.call(!value),
      trailing: AdaptiveSwitch(
        disabledIcon: disabledIcon,
        enabledIcon: enabledIcon,
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
  Curve get animationCurve => Motion.animation.emphasized;
  @override
  Widget build(context) {
    // ignore: dead_code
    if (false) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        leading: leading,
        subtitle: subtitle,
        minLeadingWidth: 25,
        title: title,
        trailing: trailing,
        enabled: !disabled,
        onTap: onTap,
      );
    }
    return InkWell(
      onTap: onTap,
      child: AnimatedOpacity(
        curve: animationCurve,
        duration: animationDuration,
        opacity: disabled ? 0.5 : 1.0,
        child: AnimatedContainer(
          constraints: const BoxConstraints(minHeight: 53),
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          duration: animationDuration,
          curve: animationCurve,
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: 24,
                    color: context.colorScheme.onSurface,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: leading,
                  ),
                ),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultTextStyle(
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.normal,
                            color: context.colorScheme.onSurface,
                          ),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const Space(0.3),
                      DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        child: subtitle!,
                      )
                    ],
                  ],
                ),
              ),
              const Space(
                1.2,
                direction: Direction.horizontal,
              ),
              Align(
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
    );
  }
}
