import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/size_listener.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class LinearProgressBar extends StatefulWidget {
  final double? width, height, radius, targetExcess, targetWidth;
  final Color? progressColor, targetColor, targetFontColor;
  final Color backgroundColor, fontColor;
  final EdgeInsets? margin, padding;
  final bool showPercentage;
  final String? targetLabel;
  final int? progress, max, target;

  const LinearProgressBar({
    super.key,
    required this.progress,
    required this.max,
    this.target,
    this.targetExcess,
    this.targetWidth,
    this.width,
    this.height,
    this.radius,
    this.showPercentage = true,
    this.backgroundColor = PanColors.grey1,
    this.fontColor = PanColors.text,
    this.progressColor,
    this.targetLabel,
    this.targetColor,
    this.targetFontColor,
    this.margin,
    this.padding,
  });

  @override
  State<LinearProgressBar> createState() =>
      LinearProgressBarState();
}

class LinearProgressBarState
    extends State<LinearProgressBar> {
  Size? _size;

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    final height = widget.height ?? d.at(15);
    return Container(
      width: widget.width,
      height: height,
      margin: widget.margin,
      padding: widget.padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(widget.radius ?? d.at(10)),
                      child: FAProgressBar(
                        backgroundColor: widget.backgroundColor,
                        currentValue: widget.progress!.toDouble(),
                        maxValue:
                            widget.max != 0 ? widget.max!.toDouble() : 1,
                        progressColor:
                            widget.progressColor ?? t.primaryColor,
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    IfElseBuilder(
                      condition: widget.target != null,
                      ifBuilder: (context) {
                        final excess = widget.targetExcess ?? 0;
                        final width = widget.targetWidth ?? d.at(2);
                        final position = (widget.target! / widget.max!) *
                            constraints.maxWidth;
                        return Positioned(
                          bottom: -excess,
                          left: math.max(
                              math.min(position - (width / 2),
                                  constraints.maxWidth - width),
                              0),
                          child: Container(
                            width: widget.targetWidth,
                            height: height + (excess * 2),
                            decoration: BoxDecoration(
                              color: widget.targetColor ?? Colors.red,
                              borderRadius: BorderRadius.circular(
                                width / 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    IfElseBuilder(
                      condition: widget.targetLabel != null,
                      ifBuilder: (context) {
                        final width = _size?.width ?? 0;
                        final position = (widget.target! / widget.max!) *
                            constraints.maxWidth;
                        return Positioned(
                          bottom: height - d.at(4),
                          left: math.max(
                              math.min(position - (width / 2),
                                  constraints.maxWidth - width),
                              0),
                          child: SizeListener(
                            onSizeChange: (size, position) {
                              if (_size == null) {
                                setState(() {
                                  _size = size;
                                });
                              }
                            },
                            child: PanText(
                              text: widget.targetLabel,
                              fontWeight: FontWeight.w500,
                              fontColor: widget.targetFontColor,
                              fontSize: d.at(10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              margin: EdgeInsets.only(
                                bottom: d.at(5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          IfElseBuilder(
            condition: widget.showPercentage,
            ifBuilder: (context) {
              return PanText(
                text: PanUtils.getPercentage(widget.progress!, widget.max!),
                fontColor: widget.fontColor,
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
