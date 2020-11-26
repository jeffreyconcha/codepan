import 'package:codepan/widgets/placeholder_handler.dart';
import 'package:flutter/material.dart';

class PanHero extends StatelessWidget {
  final HeroFlightShuttleBuilder flightShuttleBuilder;
  final HeroPlaceholderBuilder placeholderBuilder;
  final bool flexible, transitionOnUserGestures;
  final CreateRectTween createRectTween;
  final Widget child;
  final String tag;

  const PanHero({
    Key key,
    @required this.child,
    @required this.tag,
    this.transitionOnUserGestures = false,
    this.flexible = false,
    this.placeholderBuilder,
    this.flightShuttleBuilder,
    this.createRectTween,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Hero(
      tag: tag,
      transitionOnUserGestures: transitionOnUserGestures,
      placeholderBuilder: placeholderBuilder,
      flightShuttleBuilder: flightShuttleBuilder,
      createRectTween: createRectTween,
      child: Material(
        color: t.backgroundColor,
        child: PlaceholderHandler(
          condition: !flexible,
          childBuilder: (context) => child,
          placeholderBuilder: (context) {
            return SingleChildScrollView(
              child: child,
            );
          },
        ),
      ),
    );
  }
}
