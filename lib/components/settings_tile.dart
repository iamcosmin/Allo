import 'package:allo/logic/client/hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomSwitch extends HookWidget {
  const CustomSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final alignment = value ? Alignment.centerRight : Alignment.centerLeft;
    final trackOpacity = onChanged != null ? 1.0 : 0.12;
    final tokens = _TokenDefaultsM3(context);
    final disabled = onChanged == null;
    //
    //

    Color trackColor() {
      if (!disabled) {
        return value
            ? tokens.enabledTrackSelectedColor
            : tokens.enabledTrackUnselectedColor;
      } else {
        return value
            ? tokens.disabledTrackSelectedColor
                .withOpacity(tokens.disabledTrackOpacity)
            : tokens.disabledTrackUnselectedColor
                .withOpacity(tokens.disabledTrackOpacity);
      }
    }

    Color thumbColor() {
      if (!disabled) {
        return value
            ? tokens.enabledThumbSelectedColor
            : tokens.enabledThumbUnselectedColor;
      } else {
        return value
            ? tokens.disabledThumbSelectedColor
                .withOpacity(tokens.disabledThumbSelectedOpacity)
            : tokens.disabledThumbUnselectedColor
                .withOpacity(tokens.disabledThumbUnselectedOpacity);
      }
    }

    //
    //
    final switchDecoration = ShapeDecoration(
      color: trackColor(),
      shape: StadiumBorder(
        side: BorderSide(
          width: value ? 0 : 2,
          style: value ? BorderStyle.none : BorderStyle.solid,
          color: colors.outline.withOpacity(trackOpacity),
        ),
      ),
    );
    final pressed = useState(false);
    return InkWell(
      onTap: disabled
          ? null
          : () {
              pressed.value = false;
              onChanged!.call(!value);
            },
      onTapDown: disabled ? null : (_) => pressed.value = true,
      onTapCancel: disabled ? null : () => pressed.value = false,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        padding: EdgeInsets.zero,
        curve: tokens.animationCurve,
        height: 32,
        width: 52,
        alignment: alignment,
        duration: tokens.animationDuration,
        decoration: switchDecoration,
        child: AnimatedContainer(
          curve: tokens.animationCurve,
          margin: pressed.value
              ? value
                  ? tokens.pressedThumbSelectedMargin
                  : tokens.pressedThumbUnselectedMargin
              : value
                  ? tokens.thumbSelectedMargin
                  : tokens.thumbUnselectedMargin,
          duration: tokens.animationDuration,
          height: pressed.value
              ? tokens.pressedThumbRadius
              : value
                  ? tokens.thumbSelectedRadius
                  : tokens.thumbUnselectedRadius,
          width: pressed.value
              ? tokens.pressedThumbRadius
              : value
                  ? tokens.thumbSelectedRadius
                  : tokens.thumbUnselectedRadius,
          decoration: ShapeDecoration(
            color: thumbColor(),
            shape: const StadiumBorder(),
          ),
        ),
      ),
    );
  }
}

class _TokenDefaultsM3 {
  const _TokenDefaultsM3(this.context);
  final BuildContext context;

  ThemeData get _theme => Theme.of(context);
  ColorScheme get _colors => _theme.colorScheme;

  Duration get animationDuration => const Duration(milliseconds: 200);
  Curve get animationCurve => Curves.linear;

  double get outlineWidth => 2;

  double get trackHeight => 52;
  double get trackWidth => 32;
  double get thumbUnselectedRadius => 16;
  double get thumbSelectedRadius => 24;
  EdgeInsets get thumbUnselectedMargin => EdgeInsets.all(
        ((trackWidth - thumbUnselectedRadius) / 2) - outlineWidth,
      );
  EdgeInsets get thumbSelectedMargin =>
      EdgeInsets.all((trackWidth - thumbSelectedRadius) / 2);
  double get pressedThumbRadius => 28;
  EdgeInsets get pressedThumbSelectedMargin =>
      EdgeInsets.all((trackWidth - pressedThumbRadius) / 2);
  EdgeInsets get pressedThumbUnselectedMargin =>
      EdgeInsets.all(((trackWidth - pressedThumbRadius) / 2) - outlineWidth);

  Color get enabledTrackSelectedColor => _colors.primary;
  Color get enabledTrackUnselectedColor => _colors.surfaceVariant;
  Color get outlineColor => _colors.outline;
  Color get enabledThumbSelectedColor => _colors.onPrimary;
  Color get enabledThumbUnselectedColor => _colors.outline;
  Color get enabledThumbWithIconSelectedColor => _colors.onPrimaryContainer;
  Color get enabledThumbWithIconUnselectedColor => _colors.surfaceVariant;

  double get disabledTrackOpacity => 0.12;
  Color get disabledTrackSelectedColor => _colors.onSurface;
  Color get disabledTrackUnselectedColor => _colors.surfaceVariant;
  Color get disabledTrackUnselectedOutlineColor => _colors.onSurface;

  double get disabledThumbUnselectedOpacity => 0.38;
  double get disabledThumbSelectedOpacity => 1.0;
  Color get disabledThumbSelectedColor => _colors.surface;
  Color get disabledThumbUnselectedColor => _colors.onSurface;
}

class Setting extends HookConsumerWidget {
  const Setting({
    required this.title,
    super.key,
    this.enabled = true,
    this.disabledExplanation,
    this.onTap,
    this.preference,
  })  : assert(
          onTap != null || preference != null,
          'You should provide an onTap callback or a preference',
        ),
        assert(
          (onTap != null && preference == null) ||
              (onTap == null && preference != null),
          'You cannot provide both an onTap callback and a preference. Please choose one.',
        );
  final String title;
  final bool enabled;
  final String? disabledExplanation;
  final void Function()? onTap;
  final Preference? preference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void changePreference() {
      if (preference != null) {
        if (preference is Preference<bool>) {
          final value = preference!.preference;
          preference!.changeValue(!value);
        }
      }
    }

    return InkWell(
      onTap: enabled ? onTap ?? changePreference : null,
      child: Container(
        margin: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(enabled ? 1 : 0.5),
                        ),
                  ),
                ),
                if (preference != null && preference is Preference<bool>) ...[
                  SizedBox(
                    height: 32,
                    child: CustomSwitch(
                      value: preference!.preference,
                      // onChanged: null,
                      onChanged: preference!.changeValue,
                    ),
                  )
                ] else ...[
                  SizedBox(
                    height: 25,
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 19,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ]
              ],
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: enabled == false && disabledExplanation != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        disabledExplanation!,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
