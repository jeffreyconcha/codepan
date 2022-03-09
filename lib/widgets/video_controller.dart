import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/button.dart';
import 'package:codepan/widgets/icon.dart';
import 'package:codepan/widgets/if_else_builder.dart';
import 'package:codepan/widgets/loading_indicator.dart';
import 'package:codepan/widgets/media_progress_indicator.dart';
import 'package:codepan/widgets/text.dart';
import 'package:flutter/material.dart';

class VideoController extends StatelessWidget {
  final OnSeekProgress? onSeekProgress;
  final VoidCallback? onFullScreen;
  final VoidCallback? onPlay;
  final bool? isLoading;
  final bool? isInitialized;
  final bool? isPlaying;
  final bool? isFullscreen;
  final Color? color;
  final double? buffered;
  final double? current;
  final double? max;

  const VideoController({
    Key? key,
    this.isLoading,
    this.isInitialized,
    this.isPlaying,
    this.isFullscreen,
    this.color,
    this.buffered,
    this.current,
    this.max,
    this.onSeekProgress,
    this.onFullScreen,
    this.onPlay,
  }) : super(key: key);

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
                            ? color ?? Theme.of(context).primaryColor
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
                        onTap: onPlay,
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
                onSeekProgress: (value) {
                  onSeekProgress?.call(value);
                },
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
            onTap: onFullScreen,
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
    Key? key,
    required this.direction,
    this.onTap,
    this.isInitialized,
  }) : super(key: key);

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
