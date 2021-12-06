import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/widgets/pan_activity_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefresherHeader extends StatelessWidget {
  final double? indicatorRadius, statusIconSize, arrowIconSize, fontSize;
  final String? fontFamily,
      refreshingText,
      idleText,
      releaseText,
      failedText,
      completeText;

  const RefresherHeader({
    this.arrowIconSize,
    this.statusIconSize,
    this.indicatorRadius,
    this.fontSize,
    this.fontFamily,
    this.refreshingText,
    this.releaseText,
    this.idleText,
    this.failedText,
    this.completeText,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return ClassicHeader(
      height: d.at(50),
      textStyle: TextStyle(
        color: PanColors.text,
        fontSize: fontSize ?? d.at(12),
        fontFamily: fontFamily,
      ),
      refreshingText: refreshingText ?? Strings.refreshing,
      releaseText: releaseText ?? Strings.releaseToRefresh,
      idleText: idleText ?? Strings.pullDownToRefresh,
      completeText: completeText ?? Strings.completed,
      failedText: failedText ?? Errors.failedToRefresh,
      failedIcon: Icon(
        Icons.error_outline,
        color: PanColors.red1,
        size: statusIconSize ?? d.at(17),
      ),
      completeIcon: Icon(
        Icons.check_circle_outline,
        color: PanColors.green1,
        size: statusIconSize ?? d.at(17),
      ),
      releaseIcon: Icon(
        Icons.arrow_upward,
        color: PanColors.text,
        size: arrowIconSize ?? d.at(20),
      ),
      idleIcon: Icon(
        Icons.arrow_downward,
        color: PanColors.text,
        size: arrowIconSize ?? d.at(20),
      ),
      refreshingIcon: PanActivityIndicator(
        radius: indicatorRadius ?? d.at(10),
        activeColor: Colors.grey,
        inactiveColor: Colors.grey.withOpacity(0.5),
      ),
      spacing: d.at(7),
    );
  }
}
