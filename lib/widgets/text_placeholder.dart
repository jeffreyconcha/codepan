import 'package:codepan/resources/colors.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:flutter/material.dart';

class TextPlaceholder extends StatefulWidget {
  final int noOfParagraph;
  final int noOfLines;
  final Color color;

  const TextPlaceholder({
    Key key,
    @required this.noOfLines,
    @required this.noOfParagraph,
    this.color = PanColors.grey,
  }) : super(key: key);

  @override
  _TextPlaceholderState createState() => _TextPlaceholderState();
}

class _TextPlaceholderState extends State<TextPlaceholder>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animatable<Color> _tween;

  Color get color => widget.color;

  @override
  void initState() {
    _tween = TweenSequence<Color>([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: color.withOpacity(0.1),
          end: color.withOpacity(0.7),
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: color.withOpacity(0.7),
          end: color.withOpacity(0.1),
        ),
      ),
    ]);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animation = AlwaysStoppedAnimation(_controller.value);
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              alignment: Alignment.centerLeft,
              child: Column(
                children: List.generate(widget.noOfParagraph ?? 0, (index) {
                  return Container(
                    margin: EdgeInsets.only(
                      bottom: d.at(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: constraints.maxWidth * 0.75,
                          height: d.at(25),
                          color: _tween.evaluate(animation),
                          margin: EdgeInsets.only(top: d.at(10)),
                        ),
                        SizedBox(
                          height: d.at(10),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              List.generate(widget.noOfLines ?? 0, (index) {
                            final width = index % 2 != 0
                                ? constraints.maxWidth * 0.9
                                : constraints.maxWidth;
                            return Container(
                              width: width,
                              height: d.at(17),
                              color: _tween.evaluate(animation),
                              margin: EdgeInsets.only(top: d.at(10)),
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }
}
