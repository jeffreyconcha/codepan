import 'package:codepan/extensions/context.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/widgets/elevated.dart';
import 'package:flutter/material.dart';

const double dialogRadius = 10;
const double dialogMargin = 20;

class DialogContainer extends StatelessWidget {
  final VoidCallback? onDetach;
  final double? width, height;
  final EdgeInsets? margin;
  final bool dismissible;
  final Widget child;

  const DialogContainer({
    super.key,
    required this.child,
    this.margin,
    this.width,
    this.height,
    this.dismissible = true,
    this.onDetach,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return WillPopScope(
      onWillPop: () {
        return Future.value(dismissible);
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            GestureDetector(
              onTap: dismissible ? () => _detach(context) : null,
            ),
            Center(
              child: Elevated(
                width: width ?? (isDesktop ? d.at(320) : double.infinity),
                height: height,
                radius: d.at(dialogRadius),
                margin: margin ?? EdgeInsets.all(d.at(dialogMargin)),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _detach(BuildContext context) {
    context.pop();
    onDetach?.call();
  }
}
