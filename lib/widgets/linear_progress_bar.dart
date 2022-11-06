import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class LinearProgressBar extends StatelessWidget {
  final double? width, height, radius;
  final Color backgroundColor, fontColor;
  final EdgeInsets? margin, padding;
  final Color? progressColor;
  final bool showPercentage;
  final int? progress, max;

  const LinearProgressBar({
    super.key,
    required this.progress,
    required this.max,
    this.width,
    this.height,
    this.radius,
    this.showPercentage = true,
    this.backgroundColor = PanColors.grey1,
    this.fontColor = PanColors.text,
    this.progressColor,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    return Container(
      width: width,
      height: height ?? d.at(15),
      margin: margin,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                bottom: d.at(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius ?? d.at(10)),
                child: FAProgressBar(
                  backgroundColor: backgroundColor,
                  currentValue: progress!.toDouble(),
                  maxValue: max != 0 ? max!.toDouble() : 1,
                  progressColor: progressColor ?? t.primaryColor,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          ),
          IfElseBuilder(
            condition: showPercentage,
            ifBuilder: (context) {
              return PanText(
                text: PanUtils.getPercentage(progress!, max!),
                fontColor: fontColor,
                fontSize: d.at(10),
                fontWeight: FontWeight.w600,
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(
                  left: d.at(10),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
