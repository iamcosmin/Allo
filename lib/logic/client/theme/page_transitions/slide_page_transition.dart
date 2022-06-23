// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:allo/logic/client/extensions.dart';
import 'package:flutter/material.dart';

const _kDefaultCurve = Curves.fastOutSlowIn;
const _kDefaultInCurve = _kDefaultCurve;
const _kDefaultOutCurve = _kDefaultCurve;

/// Used by [PageTransitionsTheme] to define a page route transition animation
/// in which outgoing and incoming elements share a fade transition.
///
/// The shared axis pattern provides the transition animation between UI elements
/// that have a spatial or navigational relationship. For example,
/// transitioning from one page of a sign up page to the next one.
///
/// The following example shows how the SlidePageTransitionsBuilder can
/// be used in a [PageTransitionsTheme] to change the default transitions
/// of [MaterialPageRoute]s.
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     pageTransitionsTheme: PageTransitionsTheme(
///       builders: {
///         TargetPlatform.android: SlidePageTransitionsBuilder(
///           transitionType: SlidePageTransitionType.horizontal,
///         ),
///         TargetPlatform.iOS: SlidePageTransitionsBuilder(
///           transitionType: SlidePageTransitionType.horizontal,
///         ),
///       },
///     ),
///   ),
///   routes: {
///     '/': (BuildContext context) {
///       return Container(
///         color: Colors.red,
///         child: Center(
///           child: ElevatedButton(
///             child: Text('Push route'),
///             onPressed: () {
///               Navigator.of(context).pushNamed('/a');
///             },
///           ),
///         ),
///       );
///     },
///     '/a' : (BuildContext context) {
///       return Container(
///         color: Colors.blue,
///         child: Center(
///           child: ElevatedButton(
///             child: Text('Pop route'),
///             onPressed: () {
///               Navigator.of(context).pop();
///             },
///           ),
///         ),
///       );
///     },
///   },
/// );
/// ```
class SlidePageTransitionsBuilder extends PageTransitionsBuilder {
  /// Construct a [SlidePageTransitionsBuilder].
  const SlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlidePageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Defines a transition in which outgoing and incoming elements share a fade
/// transition.
///
/// The shared axis pattern provides the transition animation between UI elements
/// that have a spatial or navigational relationship. For example,
/// transitioning from one page of a sign up page to the next one.
///
/// Consider using [SlidePageTransition] within a
/// [PageTransitionsTheme] if you want to apply this kind of transition to
/// [MaterialPageRoute] transitions within a Navigator (see
/// [SlidePageTransitionsBuilder] for example code).
///
/// This transition can also be used directly in a
/// [PageTransitionSwitcher.transitionBuilder] to transition
/// from one widget to another as seen in the following example:
///
/// ```dart
/// int _selectedIndex = 0;
///
/// final List<Color> _colors = [Colors.white, Colors.red, Colors.yellow];
///
/// @override
/// Widget build(BuildContext context) {
///   return Scaffold(
///     appBar: AppBar(
///       title: const Text('Page Transition Example'),
///     ),
///     body: PageTransitionSwitcher(
///       // reverse: true, // uncomment to see transition in reverse
///       transitionBuilder: (
///         Widget child,
///         Animation<double> primaryAnimation,
///         Animation<double> secondaryAnimation,
///       ) {
///         return SlidePageTransition(
///           animation: primaryAnimation,
///           secondaryAnimation: secondaryAnimation,
///           transitionType: SlidePageTransitionType.horizontal,
///           child: child,
///         );
///       },
///       child: Container(
///         key: ValueKey<int>(_selectedIndex),
///         color: _colors[_selectedIndex],
///         child: Center(
///           child: FlutterLogo(size: 300),
///         )
///       ),
///     ),
///     bottomNavigationBar: BottomNavigationBar(
///       items: const <BottomNavigationBarItem>[
///         BottomNavigationBarItem(
///           icon: Icon(Icons.home),
///           title: Text('White'),
///         ),
///         BottomNavigationBarItem(
///           icon: Icon(Icons.business),
///           title: Text('Red'),
///         ),
///         BottomNavigationBarItem(
///           icon: Icon(Icons.school),
///           title: Text('Yellow'),
///         ),
///       ],
///       currentIndex: _selectedIndex,
///       onTap: (int index) {
///         setState(() {
///           _selectedIndex = index;
///         });
///       },
///     ),
///   );
/// }
/// ```
class SlidePageTransition extends StatelessWidget {
  /// Creates a [SlidePageTransition].
  ///
  /// The [animation] and [secondaryAnimation] argument are required and must
  /// not be null.
  const SlidePageTransition({
    required this.secondaryAnimation,
    required this.animation,
    this.fillColor,
    super.key,
    this.child,
  });

  /// The animation that drives the [child]'s entrance and exit.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.animate], which is the value given to this property
  ///    when it is used as a page transition.
  final Animation<double> animation;

  /// The animation that transitions [child] when new content is pushed on top
  /// of it.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.secondaryAnimation], which is the value given to this
  ///    property when the it is used as a page transition.
  final Animation<double> secondaryAnimation;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation] and
  /// [secondaryAnimation].
  final Widget? child;

  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (
        context,
        animation,
        child,
      ) {
        return _EnterTransition(
          animation: animation,
          child: child,
        );
      },
      reverseBuilder: (
        context,
        animation,
        child,
      ) {
        return _ExitTransition(
          animation: animation,
          fillColor: fillColor,
          reverse: true,
          child: child,
        );
      },
      child: DualTransitionBuilder(
        animation: ReverseAnimation(secondaryAnimation),
        forwardBuilder: (
          context,
          animation,
          child,
        ) {
          return _EnterTransition(
            animation: animation,
            reverse: true,
            child: child,
          );
        },
        reverseBuilder: (
          context,
          animation,
          child,
        ) {
          return _ExitTransition(
            animation: animation,
            fillColor: fillColor,
            child: child,
          );
        },
        child: child,
      ),
    );
  }
}

class _EnterTransition extends StatelessWidget {
  const _EnterTransition({
    required this.animation,
    this.reverse = false,
    this.child,
  });

  final Animation<double> animation;
  final Widget? child;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final slideInTransition = Tween<Offset>(
      begin: Offset(!reverse ? 30.0 : -30.0, 0.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: _kDefaultInCurve));
    final fadeTransition = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: _kDefaultCurve))
        .chain(CurveTween(curve: const Interval(0.2, 0.8)));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: reverse
              ? const AlwaysStoppedAnimation(1)
              : fadeTransition.animate(animation),
          child: Transform.translate(
            offset: slideInTransition.evaluate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// The animation when pressing back.
class _ExitTransition extends StatelessWidget {
  const _ExitTransition({
    required this.animation,
    this.fillColor,
    this.reverse = false,
    this.child,
  });

  final Animation<double> animation;
  final Color? fillColor;
  final bool reverse;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final slideOutTransition = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(!reverse ? -30.0 : 30.0, 0.0),
    ).chain(CurveTween(curve: _kDefaultOutCurve));
    final fadeTransition = Tween<double>(begin: 1.0, end: 0.0)
        .chain(CurveTween(curve: _kDefaultCurve))
        .chain(CurveTween(curve: const Interval(0.2, 0.8)));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          // OPACITY ONE ON ENTER, _FADEOUTTRANSITION ON EXIT
          opacity: reverse
              ? fadeTransition.animate(animation)
              : const AlwaysStoppedAnimation(1),
          child: Transform.translate(
            offset: slideOutTransition.evaluate(animation),
            child: ColoredBox(
              color: fillColor ?? context.colorScheme.surface,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
