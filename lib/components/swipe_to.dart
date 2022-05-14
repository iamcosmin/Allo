import 'package:flutter/material.dart';

/// [SwipeTo] is a widget that is used for doing an action on a horizontal swipe,
/// kind of Telegram's reply feature.
class SwipeTo extends StatefulWidget {
  /// This is the [child] that you want to horizontally swipe for an action.
  final Widget child;

  /// Duration value to define animation duration
  /// if not passed default Duration(milliseconds: 150) will be taken
  final Duration animationDuration;

  /// Icon that will be displayed beneath child widget when swipe right
  final IconData iconOnRightSwipe;

  /// Widget that will be displayed beneath child widget when swipe right
  final Widget? rightSwipeWidget;

  /// Icon that will be displayed beneath child widget when swipe left
  final IconData iconOnLeftSwipe;

  /// Widget that will be displayed beneath child widget when swipe right
  final Widget? leftSwipeWidget;

  /// double value defining size of displayed icon beneath child widget
  /// if not specified default size 26 will be taken
  final double iconSize;

  /// color value defining color of displayed icon beneath child widget
  ///if not specified primaryColor from theme will be taken
  final Color? iconColor;

  /// Double value till which position child widget will get animate when swipe left
  /// or swipe right
  /// if not specified 0.3 default will be taken for Right Swipe &
  /// it's negative -0.3 will bve taken for Left Swipe
  final double offsetDx;

  /// callback which will be initiated at the end of child widget animation
  /// when swiped right
  /// if not passed swipe to right will be not available
  final VoidCallback? onRightSwipe;

  /// callback which will be initiated at the end of child widget animation
  /// when swiped left
  /// if not passed swipe to left will be not available
  final VoidCallback? onLeftSwipe;

  const SwipeTo({
    required this.child,
    super.key,
    this.onRightSwipe,
    this.onLeftSwipe,
    this.iconOnRightSwipe = Icons.reply,
    this.rightSwipeWidget,
    this.iconOnLeftSwipe = Icons.reply,
    this.leftSwipeWidget,
    this.iconSize = 26.0,
    this.iconColor,
    this.animationDuration = const Duration(milliseconds: 150),
    this.offsetDx = 0.3,
  });

  @override
  State<SwipeTo> createState() => _SwipeToState();
}

class _SwipeToState extends State<SwipeTo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _leftIconAnimation;
  late Animation<double> _rightIconAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(curve: Curves.decelerate, parent: _controller),
    );
    _leftIconAnimation = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.0),
    );
    _rightIconAnimation = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.0),
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ///Run animation for child widget
  ///[onRight] value defines animation Offset direction
  void _runAnimation({required bool onRight}) {
    //set child animation
    _animation = Tween(
      begin: Offset.zero,
      end: Offset(onRight ? widget.offsetDx : -widget.offsetDx, 0.0),
    ).animate(
      CurvedAnimation(curve: Curves.decelerate, parent: _controller),
    );
    //set back left/right icon animation
    if (onRight) {
      _leftIconAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(curve: Curves.decelerate, parent: _controller),
      );
    } else {
      _rightIconAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(curve: Curves.decelerate, parent: _controller),
      );
    }
    //Forward animation
    _controller.forward().whenComplete(() {
      _controller.reverse().whenComplete(() {
        if (onRight) {
          //keep left icon visibility to 0.0 until onRightSwipe triggers again
          _leftIconAnimation = _controller.drive(Tween(begin: 0.0, end: 0.0));
          widget.onRightSwipe?.call();
        } else {
          //keep right icon visibility to 0.0 until onLeftSwipe triggers again
          _rightIconAnimation = _controller.drive(Tween(begin: 0.0, end: 0.0));
          widget.onLeftSwipe?.call();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (widget.onRightSwipe != null && details.delta.dx > 2) {
          _runAnimation(onRight: true);
        }
        if (widget.onLeftSwipe != null && details.delta.dx < -2) {
          _runAnimation(onRight: false);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Visibility(
                visible: widget.onRightSwipe != null,
                child: AnimatedOpacity(
                  opacity: _leftIconAnimation.value,
                  duration: widget.animationDuration,
                  curve: Curves.decelerate,
                  child: widget.rightSwipeWidget ??
                      Icon(
                        widget.iconOnRightSwipe,
                        size: widget.iconSize,
                        color: widget.iconColor ??
                            Theme.of(context).iconTheme.color,
                      ),
                ),
              ),
              Visibility(
                visible: widget.onLeftSwipe != null,
                child: AnimatedOpacity(
                  opacity: _rightIconAnimation.value,
                  duration: widget.animationDuration,
                  curve: Curves.decelerate,
                  child: widget.leftSwipeWidget ??
                      Icon(
                        widget.iconOnLeftSwipe,
                        size: widget.iconSize,
                        color: widget.iconColor ??
                            Theme.of(context).iconTheme.color,
                      ),
                ),
              ),
            ],
          ),
          SlideTransition(
            position: _animation,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
