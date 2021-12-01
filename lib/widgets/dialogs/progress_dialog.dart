import 'package:codepan/data/models/progress.dart';
import 'package:codepan/extensions/extensions.dart';
import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/resources/strings.dart';
import 'package:codepan/widgets/linear_progress_bar.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

import 'dialog_config.dart';

class ProgressDialog extends StatefulWidget {
  final String? title, message, titleFont;
  final ProgressController controller;
  final double? width, height;
  final bool dismissible;
  final Color fontColor;

  const ProgressDialog({
    Key? key,
    required this.controller,
    this.title,
    this.message = Strings.loading,
    this.dismissible = true,
    this.width,
    this.height,
    this.titleFont,
    this.fontColor = PanColors.text,
  }) : super(key: key);

  @override
  _ProgressDialogState createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  ProgressController? get controller => widget.controller;

  ProgressData? get progress => controller?.value;

  @override
  void initState() {
    controller!._initialize(() {
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
              onTap: widget.dismissible ? () => context.pop() : null,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(d.at(dialogRadius)),
                  ),
                  margin: EdgeInsets.all(dialogMargin),
                  padding: EdgeInsets.only(
                    top: d.at(20),
                    left: d.at(20),
                    right: d.at(20),
                    bottom: d.at(10),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      PanText(
                        text: widget.title,
                        fontSize: d.at(15),
                        fontFamily: widget.titleFont ?? titleFont,
                        fontWeight: FontWeight.bold,
                        fontColor: widget.fontColor,
                        alignment: Alignment.centerLeft,
                        textAlign: TextAlign.left,
                      ),
                      PanText(
                        text: widget.message,
                        fontColor: widget.fontColor,
                        fontSize: d.at(13),
                        textAlign: TextAlign.left,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.symmetric(
                          vertical: d.at(15),
                        ),
                      ),
                      LinearProgressBar(
                        progress: progress!.current,
                        max: progress!.max,
                        showPercentage: false,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: PanText(
                              text: progress!.value,
                              fontColor: widget.fontColor,
                              fontSize: d.at(11),
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: PanText(
                              text: progress!.percentValue,
                              fontColor: widget.fontColor,
                              fontSize: d.at(11),
                              alignment: Alignment.centerRight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      onWillPop: () {
        return Future.value(widget.dismissible);
      },
    );
  }
}

class ProgressController extends ValueNotifier<ProgressData> {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  ProgressController({
    ProgressData? value,
  }) : super(value ?? ProgressData.zero);

  void setProgress(ProgressData progress) {
    value = progress;
  }

  void _initialize(VoidCallback listener) {
    addListener(listener);
    setProgress(ProgressData.zero);
    _isInitialized = true;
  }

  void _reset() {
    _isInitialized = false;
  }

  bool get hasValue => value.current != 0 || value.max != 0;
}
