import 'dart:io';

import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/icon.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/pan_activity_indicator.dart';
import 'package:codepan/widgets/rotating.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final EdgeInsets? margin;
  final double? radius;
  final Color? color;
  final String? icon;
  final bool isPlatformDependent;

  const LoadingIndicator({
    super.key,
    this.radius,
    this.icon,
    this.margin,
    this.color = Colors.grey,
    this.isPlatformDependent = false,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final radius = this.radius ?? d.at(15);
    final size = radius * 2;
    return Center(
      child: IfElseBuilder(
        margin: margin,
        width: size,
        height: size,
        alignment: Alignment.center,
        condition: isPlatformDependent && Platform.isAndroid,
        ifBuilder: (context) {
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color?>(color),
          );
        },
        elseBuilder: (context) {
          return IfElseBuilder(
            condition: icon == null,
            ifBuilder: (context) {
              return PanActivityIndicator(
                radius: radius,
                isAnimating: true,
                activeColor: color!,
                inactiveColor: color!.withOpacity(0.5),
              );
            },
            elseBuilder: (context) {
              return Rotating(
                child: PanIcon(
                  icon: icon!,
                  color: color,
                  width: size,
                  height: size,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
