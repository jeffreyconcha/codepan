import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/elevated.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/line_divider.dart';
import 'package:flutter/material.dart';

class HeaderBody extends StatelessWidget {
  final Color? headerColor, backgroundColor, shadowColor;
  final double? headerHeight, shadowBlurRadius;
  final bool isElevated, withDivider;
  final Offset? shadowOffset;
  final Widget header;
  final Widget? body;

  const HeaderBody({
    Key? key,
    required this.header,
    this.body,
    this.headerHeight,
    this.headerColor = Colors.white,
    this.isElevated = true,
    this.withDivider = false,
    this.backgroundColor,
    this.shadowColor,
    this.shadowBlurRadius,
    this.shadowOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    final height = headerHeight ?? d.at(60);
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
            top: height,
          ),
          color: backgroundColor,
          child: body,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Elevated(
            color: headerColor,
            height: headerHeight ?? d.at(60),
            shadowBlurRadius: isElevated ? shadowBlurRadius ?? d.at(3) : 0,
            shadowOffset:
                isElevated ? shadowOffset ?? Offset(0, d.at(3)) : Offset.zero,
            spreadRadius: 0,
            child: Column(
              children: [
                Expanded(
                  child: header,
                ),
                IfElseBuilder(
                  condition: withDivider,
                  ifBuilder: (context) {
                    return LineDivider();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
