import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/widgets/placeholder_handler.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class LinearProgressBar extends StatelessWidget {
  final Color backgroundColor, fontColor;
  final bool showPercentage;
  final int? progress, max;
  final double? height;

  const LinearProgressBar({
    Key? key,
    required this.progress,
    required this.max,
    this.height,
    this.showPercentage = true,
    this.backgroundColor = PanColors.grey1,
    this.fontColor = PanColors.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Container(
            height: height ?? d.at(15),
            margin: EdgeInsets.only(
              bottom: d.at(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(d.at(10)),
              child: FAProgressBar(
                backgroundColor: backgroundColor,
                currentValue: progress!,
                maxValue: max != 0 ? max! : 1,
                progressColor: t.primaryColor,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
        PlaceholderHandler(
          condition: showPercentage,
          childBuilder: (context) {
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
    );
  }
}
