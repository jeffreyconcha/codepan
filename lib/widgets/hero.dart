import 'package:flutter/material.dart';

class PanHero extends StatelessWidget {
  final Widget child;
  final String tag;
  final bool transitionOnUserGestures;
  final CreateRectTween createRectTween;
  final HeroPlaceholderBuilder placeholderBuilder;
  final HeroFlightShuttleBuilder flightShuttleBuilder;

  const PanHero({
    Key key,
    @required this.child,
    @required this.tag,
    this.transitionOnUserGestures = false,
    this.placeholderBuilder,
    this.flightShuttleBuilder,
    this.createRectTween,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      transitionOnUserGestures: transitionOnUserGestures,
      placeholderBuilder: placeholderBuilder,
      flightShuttleBuilder: flightShuttleBuilder,
      createRectTween: createRectTween,
      child: Material(
        child: child,
      ),
    );
  }
}
