import 'dart:io';

import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/icon.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/pan_activity_indicator.dart';
import 'package:codepan/widgets/rotating.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double? radius;
  final Color? color;
  final String? icon;
  final bool isPlatformDependent;

  const LoadingIndicator({
    Key? key,
    this.width,
    this.height,
    this.radius,
    this.icon,
    this.margin,
    this.color = Colors.grey,
    this.isPlatformDependent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return Center(
      child: IfElseBuilder(
        width: width,
        height: height,
        margin: margin,
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
                radius: radius ?? d.at(15),
                isAnimating: true,
                activeColor: color!,
                inactiveColor: color!.withOpacity(0.5),
              );
            },
            elseBuilder: (context) {
              final size = radius != null ? radius! * 2 : null;
              return Rotating(
                child: PanIcon(
                  icon: icon!,
                  width: size ?? width,
                  height: size ?? height,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
