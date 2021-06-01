// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

/// A button in a _ContextMenuSheet.
///
/// A typical use case is to pass a [Text] as the [child] here, but be sure to
/// use [TextOverflow.ellipsis] for the [Text.overflow] field if the text may be
/// long, as without it the text will wrap to the next line.
class CupertinoCtxMenuAction extends StatefulWidget {
  /// Construct a CupertinoContextMenuAction.
  const CupertinoCtxMenuAction({
    Key? key,
    required this.child,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.onPressed,
    this.trailingIcon,
  }) : super(key: key);

  /// The widget that will be placed inside the action.
  final Widget child;

  /// Indicates whether this action should receive the style of an emphasized,
  /// default action.
  final bool isDefaultAction;

  /// Indicates whether this action should receive the style of a destructive
  /// action.
  final bool isDestructiveAction;

  /// Called when the action is pressed.
  final VoidCallback? onPressed;

  /// An optional icon to display to the right of the child.
  ///
  /// Will be colored in the same way as the [TextStyle] used for [child] (for
  /// example, if using [isDestructiveAction]).
  final IconData? trailingIcon;

  @override
  _CupertinoContextMenuActionState createState() =>
      _CupertinoContextMenuActionState();
}

class _CupertinoContextMenuActionState extends State<CupertinoCtxMenuAction> {
  static const Color _kBackgroundColor = Color(0xFFEEEEEE);
  static const Color _kBackgroundColorPressed = Color(0xFFDDDDDD);
  static const double _kButtonHeight = 40.0;
  static const double _kButtonWidth = 120;
  static const TextStyle _kActionSheetActionStyle = TextStyle(
    fontFamily: '.SF UI Text',
    inherit: false,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: CupertinoColors.black,
    textBaseline: TextBaseline.alphabetic,
  );

  final GlobalKey _globalKey = GlobalKey();
  bool _isPressed = false;

  void onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  TextStyle get _textStyle {
    if (widget.isDefaultAction) {
      return _kActionSheetActionStyle.copyWith(
        fontWeight: FontWeight.w600,
      );
    }
    if (widget.isDestructiveAction) {
      return _kActionSheetActionStyle.copyWith(
        color: CupertinoColors.destructiveRed,
      );
    }
    return _kActionSheetActionStyle;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _globalKey,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            minHeight: _kButtonHeight,
            maxHeight: _kButtonHeight,
            maxWidth: _kButtonWidth,
            minWidth: _kButtonWidth),
        child: Semantics(
          button: true,
          child: Container(
            decoration: BoxDecoration(
              color: _isPressed ? _kBackgroundColorPressed : _kBackgroundColor,
              border: const Border(
                bottom: BorderSide(width: 1.0, color: _kBackgroundColorPressed),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 5.0,
            ),
            child: DefaultTextStyle(
              style: _textStyle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: widget.child,
                  ),
                  if (widget.trailingIcon != null)
                    Icon(
                      widget.trailingIcon,
                      color: _textStyle.color,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
