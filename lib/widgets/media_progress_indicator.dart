import 'package:codepan/extensions/duration.dart';
import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

typedef OnSeekProgress = void Function(double value);

class MediaProgressIndicator extends StatelessWidget {
  final OnSeekProgress? onSeekProgress;
  final double? buffered;
  final double? current;
  final double? max;
  final double? barHeight;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color bufferedColor;
  final Color timerColor;
  final bool withShadow;

  String get currentTime {
    return Duration(
      milliseconds: current!.toInt(),
    ).format();
  }

  String get maxTime {
    return Duration(
      milliseconds: max!.toInt(),
    ).format();
  }

  const MediaProgressIndicator({
    Key? key,
    this.buffered = 0,
    this.max = 0,
    this.current = 0,
    this.barHeight,
    this.activeColor,
    this.inactiveColor,
    this.bufferedColor = Colors.white,
    this.timerColor = Colors.white,
    this.withShadow = true,
    this.onSeekProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final trackHeight = barHeight ?? d.at(4);
    final shadow = withShadow
        ? <Shadow>[
            Shadow(
              offset: Offset(d.at(1), d.at(1)),
              blurRadius: d.at(3),
              color: Colors.black,
            ),
          ]
        : null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: PanText(
                text: currentTime,
                fontColor: timerColor,
                alignment: Alignment.centerLeft,
                fontSize: 13,
                shadows: shadow,
                margin: EdgeInsets.only(left: d.at(2)),
              ),
            ),
            Expanded(
              flex: 1,
              child: PanText(
                text: maxTime,
                fontColor: timerColor,
                alignment: Alignment.centerRight,
                fontSize: 13,
                shadows: shadow,
                margin: EdgeInsets.only(right: d.at(2)),
              ),
            ),
          ],
        ),
        Container(
          height: d.at(20),
          margin: EdgeInsets.only(bottom: d.at(10)),
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  height: trackHeight,
                  padding: EdgeInsets.symmetric(horizontal: d.at(2)),
                  child: LinearProgressIndicator(
                    backgroundColor:
                        inactiveColor ?? Colors.white.withOpacity(0.3),
                    value: buffered,
                    valueColor: AlwaysStoppedAnimation<Color>(bufferedColor),
                  ),
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  thumbColor: activeColor,
                  trackShape: TrackShape(),
                  trackHeight: trackHeight,
                  thumbShape: RectangularThumb(
                    width: d.at(4),
                    height: d.at(13),
                  ),
                ),
                child: Slider(
                  max: max!,
                  value: current!,
                  activeColor: activeColor,
                  inactiveColor: Colors.transparent,
                  onChanged: onSeekProgress,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class TrackShape extends RectangularSliderTrackShape {
  double get disabledThumbGapWidth => 0;

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final size = parentBox.size;
    final double height = sliderTheme.trackHeight!;
    final double top = offset.dy + (size.height - height) / 2;
    final double left = offset.dx;
    final double width = size.width;
    return Rect.fromLTWH(left, top, width, height);
  }
}

class RectangularThumb extends SliderComponentShape {
  final double? width;
  final double? height;

  const RectangularThumb({
    this.width,
    this.height,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(0, 0);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    required SliderThemeData sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final rect = Rect.fromCenter(
      center: center,
      width: width!,
      height: height!,
    );
    final paint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }
}
