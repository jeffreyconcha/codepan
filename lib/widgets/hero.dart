import 'package:codepan/widgets/if_else_builder.dart';
import 'package:flutter/material.dart';

class PanHero extends StatelessWidget {
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;
  final bool flexible, transitionOnUserGestures;
  final CreateRectTween? tween;
  final String tag;
  final Widget child;

  const PanHero({
    Key? key,
    required this.child,
    required this.tag,
    this.tween,
    this.flexible = false,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
    this.transitionOnUserGestures = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Hero(
      tag: tag,
      transitionOnUserGestures: transitionOnUserGestures,
      placeholderBuilder: placeholderBuilder,
      flightShuttleBuilder: flightShuttleBuilder,
      createRectTween: tween,
      child: Material(
        color: t.backgroundColor,
        child: IfElseBuilder(
          condition: !flexible,
          ifBuilder: (context) => child,
          elseBuilder: (context) {
            return SingleChildScrollView(
              child: child,
            );
          },
        ),
      ),
    );
  }
}
