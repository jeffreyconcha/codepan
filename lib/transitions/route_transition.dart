import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const delay = Duration(milliseconds: 250);

typedef OnScreenTransition = Future<Widget> Function();

class SlideRoute extends PageRouteBuilder {
  final RouteSettings settings;
  final Duration? duration;
  final Widget? exit;
  final Widget enter;

  SlideRoute({
    required this.enter,
    this.exit,
    this.duration,
    this.settings = const RouteSettings(name: 'slide'),
  }) : super(
          transitionDuration: duration ?? delay,
          pageBuilder: (context, animation1, animation2) => enter,
          transitionsBuilder: (context, animation1, animation2, child) {
            var t1 = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(-0.25, 0),
            );
            var t2 = Tween<Offset>(
              begin: Offset(1, 0),
              end: Offset.zero,
            );
            return Stack(
              children: [
                SlideTransition(
                  position: animation1.drive(t1),
                  child: exit,
                ),
                SlideTransition(
                  position: animation1.drive(t2),
                  child: enter,
                ),
              ],
            );
          },
          settings: settings,
        );
}

class FadeRoute extends PageRouteBuilder {
  final RouteSettings settings;
  final Duration? duration;
  final Widget enter;

  FadeRoute({
    required this.enter,
    this.duration,
    this.settings = const RouteSettings(name: 'fade'),
  }) : super(
          transitionDuration: duration ?? delay,
          pageBuilder: (context, animation1, animation2) => enter,
          transitionsBuilder: (context, animation1, animation2, child) {
            return FadeTransition(
              opacity: animation1,
              child: child,
            );
          },
          settings: settings,
        );
}

class BottomModalRoute extends PageRouteBuilder {
  final RouteSettings settings;
  final Duration? duration;
  final Widget enter;

  BottomModalRoute({
    required this.enter,
    this.duration,
    this.settings = const RouteSettings(name: 'modal'),
  }) : super(
          opaque: false,
          barrierColor: Colors.black45,
          barrierDismissible: true,
          transitionDuration: duration ?? delay,
          pageBuilder: (context, animation1, animation2) => enter,
          transitionsBuilder: (context, animation1, animation2, child) {
            return SlideTransition(
              position: animation1.drive(
                Tween(
                  begin: Offset(0, 1),
                  end: Offset.zero,
                ).chain(
                  CurveTween(
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
              child: child,
            );
          },
          settings: settings,
        );
}
