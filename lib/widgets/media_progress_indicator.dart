import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnSeekProgress = void Function(double value);

class MediaProgressIndicator extends StatelessWidget {
  final OnSeekProgress onSeekProgress;
  final double buffered;
  final double current;
  final double max;
  final barHeight;
  final Color color;

  String get currentTime {
    return PanUtils.formatDuration(Duration(
      milliseconds: current.toInt(),
    ));
  }

  String get maxTime {
    return PanUtils.formatDuration(Duration(
      milliseconds: max.toInt(),
    ));
  }

  const MediaProgressIndicator({
    Key key,
    this.buffered = 0,
    this.max = 0,
    this.current = 0,
    this.barHeight,
    this.color,
    this.onSeekProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final trackHeight = barHeight ?? d.at(4);
    final shadow = <Shadow>[
      Shadow(
        offset: Offset(d.at(1), d.at(1)),
        blurRadius: d.at(3),
        color: Colors.black,
      ),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: d.at(20)),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: PanText(
                  text: currentTime,
                  fontColor: Colors.white,
                  alignment: Alignment.centerLeft,
                  fontSize: 13,
                  shadows: shadow,
                ),
              ),
              Expanded(
                flex: 1,
                child: PanText(
                  text: maxTime,
                  fontColor: Colors.white,
                  alignment: Alignment.centerRight,
                  fontSize: 13,
                  shadows: shadow,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: d.at(20),
          margin: EdgeInsets.only(bottom: d.at(10)),
          padding: EdgeInsets.symmetric(
            horizontal: d.at(20),
          ),
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  height: trackHeight,
                  padding: EdgeInsets.symmetric(horizontal: d.at(2)),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.3),
                    value: buffered,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  thumbColor: color,
                  trackShape: TrackShape(),
                  trackHeight: trackHeight,
                ),
                child: Slider(
                  max: max,
                  value: current,
                  activeColor: color,
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
  @override
  double get disabledThumbGapWidth => 0;

  @override
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double height = sliderTheme.trackHeight;
    final double top = offset.dy + (parentBox.size.height - height) / 2;
    final double left = offset.dx;
    final double width = parentBox.size.width;
    return Rect.fromLTWH(left, top, width, height);
  }
}
