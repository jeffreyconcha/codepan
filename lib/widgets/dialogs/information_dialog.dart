import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/button.dart';
import 'package:codepan/widgets/elevated.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/line_divider.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

import 'dialog_config.dart';

class InformationDialog extends StatefulWidget {
  final String? title, message, positive, negative, titleFont;
  final VoidCallback? onPositiveTap, onNegativeTap, onDetach;
  final bool dismissible, withDivider, autoDismiss;
  final InformationController? controller;
  final List<InlineSpan>? children;
  final EdgeInsets? margin;
  final Color fontColor;
  final Widget? child;

  const InformationDialog({
    Key? key,
    this.child,
    this.children,
    this.controller,
    this.dismissible = true,
    this.message,
    this.negative,
    this.onDetach,
    this.onNegativeTap,
    this.onPositiveTap,
    this.positive,
    this.title,
    this.withDivider = true,
    this.titleFont,
    this.fontColor = PanColors.text,
    this.margin,
    this.autoDismiss = true,
  }) : super(key: key);

  @override
  _InformationDialogState createState() => _InformationDialogState();
}

class _InformationDialogState extends State<InformationDialog> {
  late InformationController _controller;

  String? get message => _controller.value;

  String? get positive => widget.positive;

  String? get negative => widget.negative;

  @override
  void initState() {
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = InformationController(value: widget.message);
    }
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final t = Theme.of(context);
    final titleFont = t.dialogTheme.titleTextStyle?.fontFamily;
    return WillPopScope(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: widget.dismissible ? () => _detach(context) : null,
            ),
            Center(
              child: Elevated(
                radius: d.at(dialogRadius),
                margin: widget.margin ?? EdgeInsets.all(d.at(dialogMargin)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: PanText(
                            text: widget.title,
                            fontSize: d.at(15),
                            fontFamily: widget.titleFont ?? titleFont,
                            fontWeight: FontWeight.w600,
                            fontColor: widget.fontColor,
                            alignment: Alignment.centerLeft,
                            textAlign: TextAlign.left,
                            padding: EdgeInsets.symmetric(
                              horizontal: d.at(20),
                              vertical: d.at(13),
                            ),
                          ),
                        ),
                        PanButton(
                          width: d.at(40),
                          height: d.at(40),
                          radius: d.at(20),
                          child: Icon(
                            Icons.close,
                            color: PanColors.text,
                            size: d.at(20),
                          ),
                          onTap: () => context.pop(),
                          margin: EdgeInsets.only(
                            right: d.at(5),
                          ),
                        ),
                      ],
                    ),
                    IfElseBuilder(
                      condition: widget.withDivider,
                      ifBuilder: (context) {
                        return LineDivider();
                      },
                    ),
                    IfElseBuilder(
                      condition: widget.child != null,
                      ifBuilder: (context) => widget.child!,
                      elseBuilder: (context) {
                        return PanText(
                          text: message,
                          fontSize: d.at(13),
                          fontColor: widget.fontColor,
                          alignment: Alignment.centerLeft,
                          textAlign: TextAlign.left,
                          spannable: SpannableText(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            identifiers: ['<s>', '</s>'],
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: d.at(20),
                            vertical: d.at(13),
                          ),
                          children: widget.children,
                        );
                      },
                    ),
                    IfElseBuilder(
                        color: Colors.white,
                        condition: positive != null || negative != null,
                        ifBuilder: (context) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: d.at(20),
                              vertical: d.at(7),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IfElseBuilder(
                                  condition: positive != null,
                                  ifBuilder: (context) {
                                    return PanButton(
                                      text: widget.positive,
                                      fontColor: t.primaryColor,
                                      fontSize: d.at(13),
                                      fontWeight: FontWeight.w600,
                                      radius: d.at(3),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: d.at(15),
                                        vertical: d.at(10),
                                      ),
                                      onTap: () {
                                        if (widget.autoDismiss) {
                                          _detach(context);
                                        }
                                        widget.onPositiveTap?.call();
                                      },
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: d.at(10),
                                ),
                                IfElseBuilder(
                                  condition: negative != null,
                                  ifBuilder: (context) {
                                    return PanButton(
                                      text: widget.negative,
                                      fontColor: widget.fontColor,
                                      fontSize: d.at(13),
                                      fontWeight: FontWeight.w600,
                                      radius: d.at(3),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: d.at(15),
                                        vertical: d.at(10),
                                      ),
                                      onTap: () {
                                        if (widget.autoDismiss) {
                                          _detach(context);
                                        }
                                        widget.onNegativeTap?.call();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () {
        return Future.value(widget.dismissible);
      },
    );
  }

  void _detach(BuildContext context) {
    context.pop();
    widget.onDetach?.call();
  }
}

class InformationController extends ValueNotifier<String> {
  InformationController({
    String? value,
  }) : super(value ?? '');

  void setMessage(String message) {
    value = message;
  }
}
