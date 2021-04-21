import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const delay = Duration(milliseconds: 250);

typedef OnScreenTransition = Future<Widget> Function();

class SlideRoute extends PageRouteBuilder {
  final Widget? exit;
  final Widget enter;
  final RouteSettings settings;

  SlideRoute({
    this.exit,
    required this.enter,
    this.settings = const RouteSettings(name: 'slide'),
  }) : super(
          transitionDuration: delay,
          pageBuilder: (context, animation1, animation2) => enter,
          transitionsBuilder: (context, animation1, animation2, child) {
            var t1 = Tween<Offset>(begin: Offset.zero, end: Offset(-0.25, 0));
            var t2 = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero);
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
  final Widget enter;
  final RouteSettings settings;

  FadeRoute({
    required this.enter,
    this.settings = const RouteSettings(name: 'fade'),
  }) : super(
          transitionDuration: delay,
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
