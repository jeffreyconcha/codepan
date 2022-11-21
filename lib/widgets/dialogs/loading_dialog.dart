import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/widgets/elevated.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final Widget? indicator;
  final bool dismissible;
  final Color fontColor;
  final String? message;
  final double? width;
  final double? height;

  const LoadingDialog({
    super.key,
    this.message = Strings.loading,
    this.width,
    this.height,
    this.dismissible = true,
    this.fontColor = PanColors.text,
    this.indicator,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return WillPopScope(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: dismissible
                  ? () {
                      context.pop();
                    }
                  : null,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Elevated(
                    width: width ?? d.at(200),
                    height: height,
                    radius: d.at(3),
                    padding: EdgeInsets.symmetric(
                      vertical: d.at(10),
                      horizontal: d.at(15),
                    ),
                    child: Row(
                      children: <Widget>[
                        indicator ?? LoadingIndicator(),
                        Expanded(
                          child: PanText(
                            text: message,
                            fontColor: fontColor,
                            fontSize: d.at(13),
                            margin: EdgeInsets.only(
                              left: d.at(10),
                            ),
                            textAlign: TextAlign.left,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      onWillPop: () {
        return Future.value(dismissible);
      },
    );
  }
}
