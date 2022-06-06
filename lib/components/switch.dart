import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    required this.value,
    this.onChanged,
    super.key,
  });

  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return _Switch(
          value: value,
          onChanged: onChanged,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        );
    }
  }
}

class _Switch extends HookWidget {
  const _Switch({
    required this.value,
    required this.onChanged,
    // ignore: unused_element
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
