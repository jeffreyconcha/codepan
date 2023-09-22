import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/button.dart';
import 'package:codepan/widgets/icon.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/media_progress_indicator.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

class VideoController extends StatelessWidget {
  final bool? isLoading, isInitialized, isPlaying, isFullscreen;
  final VoidCallback? onTapFullScreen, onTapPlay, onTapSubtitle;
  final WidgetBuilder? subtitleBuilder;
  final Color? color, playButtonColor;
  final OnSeekProgress? onSeekProgress;
  final double? buffered;
  final double? current;
  final double? max;
  final bool withSubtitle;

  const VideoController({
    super.key,
    this.isLoading,
    this.isInitialized,
    this.isPlaying,
    this.isFullscreen,
    this.color,
    this.playButtonColor,
    this.buffered,
    this.current,
    this.max,
    this.onSeekProgress,
    this.onTapFullScreen,
    this.onTapPlay,
    this.onTapSubtitle,
    this.withSubtitle = false,
    this.subtitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return Stack(
      children: <Widget>[
        Center(
          child: IfElseBuilder(
            condition: !isLoading!,
            ifBuilder: (context) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: SkipButton(
                      direction: Direction.backward,
                      onTap: () {
                        onSeekProgress?.call(current! - 10000);
                      },
                      isInitialized: isInitialized,
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: PanButton(
                        background: !isInitialized!
                            ? playButtonColor ?? Theme.of(context).primaryColor
                            : Colors.transparent,
                        radius: d.at(70),
                        width: d.at(70),
                        height: d.at(70),
                        child: Icon(
                          isPlaying! ? Icons.pause : Icons.play_arrow,
                          size: isInitialized! ? d.at(50) : d.at(40),
                          color: Colors.white,
                        ),
                        splashColor: Colors.white.withOpacity(0.4),
                        highlightColor: Colors.transparent,
                        onTap: onTapPlay,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: SkipButton(
                      direction: Direction.forward,
                      onTap: () {
                        onSeekProgress?.call(current! + 10000);
                      },
                      isInitialized: isInitialized,
                    ),
                  ),
                ],
              );
            },
            elseBuilder: (context) {
              return LoadingIndicator(
                color: color,
              );
            },
          ),
        ),
        IfElseBuilder(
          alignment: Alignment.bottomCenter,
          condition: isInitialized,
          ifBuilder: (context) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: d.at(20),
              ),
              child: MediaProgressIndicator(
                activeColor: color,
                buffered: buffered,
                current: current,
                max: max,
                withShadow: false,
                onSeekProgress: (value) {
                  onSeekProgress?.call(value);
                },
              ),
            );
          },
        ),
        IfElseBuilder(
          condition: withSubtitle,
          ifBuilder: (context) {
            return Align(
              alignment: Alignment.topLeft,
              child: subtitleBuilder?.call(context) ??
                  PanButton(
                    radius: d.at(50),
                    width: d.at(40),
                    height: d.at(40),
                    margin: EdgeInsets.all(d.at(5)),
                    alignment: Alignment.center,
                    splashColor: Colors.white.withOpacity(0.4),
                    highlightColor: Colors.transparent,
                    child: Icon(
                      Icons.subtitles_outlined,
                      size: d.at(25),
                      color: Colors.white,
                    ),
                    onTap: onTapSubtitle,
                  ),
            );
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PanButton(
            radius: d.at(50),
            width: d.at(40),
            height: d.at(40),
            margin: EdgeInsets.all(d.at(5)),
            alignment: Alignment.center,
            splashColor: Colors.white.withOpacity(0.4),
            highlightColor: Colors.transparent,
            child: Icon(
              isFullscreen! ? Icons.fullscreen_exit : Icons.fullscreen,
              size: d.at(30),
              color: Colors.white,
            ),
            onTap: onTapFullScreen,
          ),
        ),
      ],
    );
  }
}

enum Direction {
  backward,
  forward,
}

class SkipButton extends StatelessWidget {
  final Direction direction;
  final VoidCallback? onTap;
  final bool? isInitialized;

  const SkipButton({
    super.key,
    required this.direction,
    this.onTap,
    this.isInitialized,
  });

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final isForward = direction == Direction.forward;
    return IfElseBuilder(
      alignment: isForward ? Alignment.centerLeft : Alignment.centerRight,
      condition: isInitialized,
      ifBuilder: (context) {
        return PanButton(
          radius: d.at(60),
          width: d.at(60),
          height: d.at(60),
          margin: EdgeInsets.only(
            top: d.at(20),
          ),
          splashColor: Colors.white.withOpacity(0.4),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PanIcon(
                icon: isForward ? 'fast_forward' : 'fast_rewind',
                width: d.at(20),
                height: d.at(18),
                isInternal: true,
              ),
              PanText(
                text: '10',
                fontColor: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                margin: EdgeInsets.only(top: d.at(3)),
              )
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }
}
