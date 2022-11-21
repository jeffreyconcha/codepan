import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/widgets/elevated.dart';
import 'package:flutter/material.dart';

const double dialogRadius = 10;
const double dialogMargin = 20;

class DialogContainer extends StatelessWidget {
  final double? width, height;
  final EdgeInsets? margin;
  final Widget child;

  const DialogContainer({
    super.key,
    required this.child,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return Center(
      child: Elevated(
        width: width ?? (isDesktop ? d.at(320) : double.infinity),
        height: height,
        radius: d.at(dialogRadius),
        margin: margin,
        child: child,
      ),
    );
  }
}
