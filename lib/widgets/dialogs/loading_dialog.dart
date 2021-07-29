import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final bool dismissible;
  final Color fontColor;
  final String? message;
  final double? width;
  final double? height;

  const LoadingDialog({
    Key? key,
    this.message = Strings.loading,
    this.width,
    this.height,
    this.dismissible = true,
    this.fontColor = PanColors.text,
  }) : super(key: key);

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
                  Container(
                    width: width ?? d.at(200),
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(d.at(3)),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: d.at(10),
                      horizontal: d.at(15),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        LoadingIndicator(),
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