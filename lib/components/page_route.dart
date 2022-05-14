// ignore_for_file: prefer_asserts_with_message

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Used by [PageTransitionsTheme] to define a horizontal [MaterialPageRoute]
/// page transition animation that matches [SwipeablePageRoute].
///
/// See [SwipeablePageRoute] for documentation of all properties.
///
/// ⚠️ [SwipeablePageTransitionsBuilder] *must* be set for [TargetPlatform.iOS].
/// For all other platforms, you can decide whether you want to use it. This is
/// because [PageTransitionsTheme] uses the builder for iOS whenever a pop
/// gesture is in progress.
class SwipeablePageTransitionsBuilder extends PageTransitionsBuilder {
  const SwipeablePageTransitionsBuilder({
    this.transitionBuilder,
  });

  final SwipeableTransitionBuilder? transitionBuilder;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SwipeablePageRoute.buildPageTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

/// A specialized [CupertinoPageRoute] that allows for swiping back anywhere on
/// the page unless `canOnlySwipeFromEdge` is `true`.
class SwipeablePageRoute<T> extends CupertinoPageRoute<T> {
  SwipeablePageRoute({
    required super.builder,
    super.title,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  static SwipeableTransitionBuilder _defaultTransitionBuilder(
    bool fullscreenDialog,
  ) {
    if (fullscreenDialog) {
      return (context, animation, secondaryAnimation, isSwipeGesture, child) {
        return SharedAxisTransition(
          transitionType: SharedAxisTransitionType.vertical,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      };
    } else {
      return (context, animation, secondaryAnimation, isSwipeGesture, child) {
        return SharedAxisTransition(
          animation: animation,
          fillColor: Theme.of(context).backgroundColor,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      };
    }
  }

  @override
  bool get popGestureEnabled {
    // If there's nothing to go back to, then obviously we don't support
    // the back gesture.
    if (
        // If the route wouldn't actually pop if we popped it, then the gesture
        // would be really confusing (or would skip internal routes), so disallow it.
        isFirst ||
            // If the route wouldn't actually pop if we popped it, then the gesture
            // would be really confusing (or would skip internal routes), so disallow it.
            willHandlePopInternally ||
            // If attempts to dismiss this route might be vetoed such as in a page
            // with forms, then do not allow the user to dismiss the route with a swipe.
            hasScopedWillPopCallback ||
            // Fullscreen dialogs aren't dismissible by back swipe.
            fullscreenDialog ||
            // If we're in an animation already, we cannot be manually swiped.
            animation!.status != AnimationStatus.completed ||
            // If we're being popped into, we also cannot be swiped until the pop above
            // it completes. This translates to our secondary animation being
            // dismissed.
            secondaryAnimation!.status != AnimationStatus.dismissed ||
            // If we're in a gesture already, we cannot start another.
            CupertinoRouteTransitionMixin.isPopGestureInProgress(this)) {
      return false;
    }
    // Looks like a back gesture would be welcome!
    return true;
  }

  // Called by `_FancyBackGestureDetector` when a pop ("back") drag start
  // gesture is detected. The returned controller handles all of the subsequent
  // drag events.
  static _CupertinoBackGestureController<T> _startPopGesture<T>(
    PageRoute<T> route,
  ) {
    return _CupertinoBackGestureController<T>(
      navigator: route.navigator!,
      controller: route.controller!, // protected access
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildPageTransitions(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  static Widget buildPageTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Widget wrappedChild;
    if (route.fullscreenDialog) {
      wrappedChild = child;
    } else {
      wrappedChild = _FancyBackGestureDetector<T>(
        onStartPopGesture: () {
          return _startPopGesture(route);
        },
        child: child,
      );
    }

    return _defaultTransitionBuilder(route.fullscreenDialog)(
      context,
      animation,
      secondaryAnimation,
      /* isSwipeGesture: */ CupertinoRouteTransitionMixin
          .isPopGestureInProgress(route),
      wrappedChild,
    );
  }
}

typedef SwipeableTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  bool isSwipeGesture,
  Widget child,
);

extension BuildContextSwipeablePageRoute on BuildContext {
  SwipeablePageRoute<T>? getSwipeablePageRoute<T>() {
    final route = ModalRoute.of<T>(this);
    return route is SwipeablePageRoute<T> ? route : null;
  }

  TextDirection get directionality {
    return Directionality.of(this);
  }

  MediaQueryData get mediaQuery {
    return MediaQuery.of(this);
  }
}

// Mostly copies and modified variations of the private widgets related to
// [CupertinoPageRoute].

const double _kMinFlingVelocity = 1; // Screen widths per second.

// An eyeballed value for the maximum time it takes for a page to animate
// forward if the user releases a page mid swipe.
const int _kMaxDroppedSwipePageForwardAnimationTime = 800; // Milliseconds.

// The maximum time for a page to get reset to it's original position if the
// user releases a page mid swipe.
const int _kMaxPageBackAnimationTime = 300; // Milliseconds.

class _FancyBackGestureDetector<T> extends StatefulWidget {
  const _FancyBackGestureDetector({
    required this.onStartPopGesture,
    required this.child,
    super.key,
  });

  final Widget child;
  final ValueGetter<_CupertinoBackGestureController<T>> onStartPopGesture;

  @override
  _FancyBackGestureDetectorState<T> createState() =>
      _FancyBackGestureDetectorState<T>();
}

class _FancyBackGestureDetectorState<T>
    extends State<_FancyBackGestureDetector<T>> {
  _CupertinoBackGestureController<T>? _backGestureController;

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_backGestureController == null);
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController!.dragUpdate(
      _convertToLogical(details.primaryDelta! / context.size!.width * 1.25),
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    assert(_backGestureController != null);
    _backGestureController!.dragEnd(
      _convertToLogical(
        details.velocity.pixelsPerSecond.dx / context.size!.width,
      ),
    );
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    // This can be called even if start is not called, paired with the "down"
    // event that we don't consider here.
    _backGestureController?.dragEnd(0);
    _backGestureController = null;
  }

  double _convertToLogical(double value) {
    switch (context.directionality) {
      case TextDirection.rtl:
        return -value;
      case TextDirection.ltr:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final gestureDetector = RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        _DirectionDependentDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                _DirectionDependentDragGestureRecognizer>(
          () {
            final directionality = context.directionality;
            return _DirectionDependentDragGestureRecognizer(
              debugOwner: this,
              canDragToLeft: directionality == TextDirection.rtl,
              canDragToRight: directionality == TextDirection.ltr,
              checkStartedCallback: () => _backGestureController != null,
            );
          },
          (instance) => instance
            ..onStart = _handleDragStart
            ..onUpdate = _handleDragUpdate
            ..onEnd = _handleDragEnd
            ..onCancel = _handleDragCancel,
        )
      },
    );

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(child: gestureDetector),
      ],
    );
  }
}

// Copied from `flutter/cupertino`.
class _CupertinoBackGestureController<T> {
  _CupertinoBackGestureController({
    required this.navigator,
    required this.controller,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  /// The drag gesture has changed by [delta]. The total range of the
  /// drag should be 0.0 to 1.0.
  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// The drag gesture has ended with a horizontal motion of [velocity] as a
  /// fraction of screen width per second.
  void dragEnd(double velocity) {
    // Fling in the appropriate direction.
    // AnimationController.fling is guaranteed to
    // take at least one frame.
    //
    // This curve has been determined through rigorously eyeballing native iOS
    // animations.
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    // If the user releases the page before mid screen with sufficient velocity,
    // or after mid screen, we should animate the page out. Otherwise, the page
    // should be animated back in.
    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      // The closer the panel is to dismissing, the shorter the animation is.
      // We want to cap the animation time, but we want to use a linear curve
      // to determine it.
      final droppedPageForwardAnimationTime = math.min(
        lerpDouble(
          _kMaxDroppedSwipePageForwardAnimationTime,
          0,
          controller.value,
        )!
            .floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(
        1,
        duration: Duration(milliseconds: droppedPageForwardAnimationTime),
        curve: Curves.easeInOutQuint,
      );
    } else {
      // This route is destined to pop at this point. Reuse navigator's pop.
      navigator.maybePop();

      // The popping may have finished inline if already at the target
      // destination.
      if (controller.isAnimating) {
        // Otherwise, use a custom popping animation duration and curve.
        final droppedPageBackAnimationTime = lerpDouble(
          0,
          _kMaxDroppedSwipePageForwardAnimationTime,
          controller.value,
        )!
            .floor();
        controller.animateBack(
          0,
          duration: Duration(milliseconds: droppedPageBackAnimationTime),
          curve: animationCurve,
        );
      }
    }

    if (controller.isAnimating) {
      // Keep the userGestureInProgress in true state so we don't change the
      // curve of the page transition mid-flight since CupertinoPageTransition
      // depends on userGestureInProgress.
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}

class _DirectionDependentDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  _DirectionDependentDragGestureRecognizer({
    required this.canDragToLeft,
    required this.canDragToRight,
    required this.checkStartedCallback,
    super.debugOwner,
  });

  final bool canDragToLeft;
  final bool canDragToRight;
  final ValueGetter<bool> checkStartedCallback;

  @override
  void handleEvent(PointerEvent event) {
    final delta = event.delta.dx;
    if (checkStartedCallback() ||
        (canDragToLeft && delta < 0 ||
            canDragToRight && delta > 0 ||
            delta == 0)) {
      super.handleEvent(event);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }
}
