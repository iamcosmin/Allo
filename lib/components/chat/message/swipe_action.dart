import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// A draggable card that moves back to [Alignment.center] when it's
/// released.
class SwipeAction extends StatefulWidget {
  const SwipeAction({
    required this.child,
    required this.action,
    required this.callback,
    required this.alignment,
    super.key,
  });

  final Widget child;
  final Widget action;
  final void Function() callback;
  final Alignment alignment;

  @override
  State<SwipeAction> createState() => _SwipeActionState();
}

class _SwipeActionState extends State<SwipeAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// The alignment of the card as it is dragged or being animated.
  ///
  /// While the card is being dragged, this value is set to the values computed
  /// in the GestureDetector onPanUpdate callback. If the animation is running,
  /// this value is set to the value of the [_animation].
  late Alignment _dragAlignment;

  late Animation<Alignment> _animation;

  double straightDigit(double digit) {
    if (digit < 0.0) {
      return 0.0;
    }
    if (digit > 1.0) {
      return 1.0;
    }
    return digit;
  }

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    final double = widget.alignment == Alignment.centerRight
        ? straightDigit(1.0 - _dragAlignment.x)
        : straightDigit(1.0 + _dragAlignment.x);
    if (double == 1.0) {
      HapticFeedback.mediumImpact();
      widget.callback();
    }
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: widget.alignment,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 20,
      stiffness: 1,
      damping: 1,
    );

    final simulation = ScrollSpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _dragAlignment = widget.alignment;
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double = widget.alignment == Alignment.centerRight
        ? straightDigit(1.0 - _dragAlignment.x)
        : straightDigit(1.0 + _dragAlignment.x);

    return Stack(
      alignment: widget.alignment,
      children: [
        Opacity(
          opacity: double,
          child: Stack(
            alignment: Alignment.center,
            children: [
              widget.action,
              CircularProgressIndicator(
                strokeWidth: 2,
                value: double,
              ),
            ],
          ),
        ),
        GestureDetector(
          onPanDown: (details) {
            _controller.stop();
          },
          onPanUpdate: (details) {
            setState(() {
              _dragAlignment += Alignment(
                details.delta.dx / (size.width / 1.5),
                0,
              );
            });
            // print(_dragAlignment.x);
          },
          onPanEnd: (details) {
            _runAnimation(details.velocity.pixelsPerSecond, size);
          },
          child: Align(
            alignment: _dragAlignment,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
