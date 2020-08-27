import 'dart:io';

import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/pan_activity_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;
  final bool isPlatformDependent;

  const LoadingIndicator({
    Key key,
    this.width,
    this.height,
    this.color,
    this.radius,
    this.isPlatformDependent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return Center(
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: isPlatformDependent && Platform.isAndroid
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(color),
              )
            : PanActivityIndicator(
                radius: radius ?? d.at(15),
                animating: true,
                activeColor: Colors.grey,
                inactiveColor: Colors.grey.withOpacity(0.5),
              ),
      ),
    );
  }
}
