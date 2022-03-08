import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/size_listener.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatefulWidget {
  final Widget? header, loading, placeholder, floating;
  final VoidCallback? onRefresh, onLoading, onScrollToMax;
  final bool isLoading, enablePullDown;
  final RefreshController controller;
  final int? itemCount;
  final Widget child;

  const PullToRefresh({
    Key? key,
    required this.controller,
    required this.child,
    this.placeholder,
    this.header,
    this.loading,
    this.isLoading = false,
    this.enablePullDown = true,
    this.itemCount,
    this.onRefresh,
    this.onLoading,
    this.onScrollToMax,
    this.floating,
  }) : super(key: key);

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh> {
  double _offset = 0;
  double _pixels = 0;
  Size? _size;

  RefreshController get controller => widget.controller;

  Widget? get floating => widget.floating;

  double get height => _size?.height ?? 0;

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final children = <Widget>[
      NotificationListener(
        child: SmartRefresher(
          header: widget.header,
          controller: controller,
          enablePullDown: widget.enablePullDown,
          child:
              widget.isLoading && !controller.isRefresh
              ? widget.loading ?? widget.child
                  : widget.itemCount == 0
                      ? widget.placeholder ?? widget.child
                      : widget.child,
          physics: widget.isLoading && controller.isRefresh
              ? NeverScrollableScrollPhysics()
              : null,
          onRefresh: widget.onRefresh,
          onLoading: widget.onLoading,
        ),
        onNotification: (data) {
          if (data is ScrollUpdateNotification) {
            final delta = data.scrollDelta ?? 0;
            final metrics = data.metrics;
            final pixels = metrics.pixels;
            if (floating != null) {
              if (pixels <= 0) {
                setState(() {
                  if (controller.isRefresh) {
                    _offset += delta;
                  } else {
                    _offset = pixels;
                  }
                });
              } else {
                final offset = _offset + delta;
                if (pixels > _pixels) {
                  if (_offset < height) {
                    setState(() {
                      _offset = offset < height ? offset : height;
                    });
                  }
                } else {
                  if (_offset > 0) {
                    setState(() {
                      _offset = offset > 0 ? offset : 0;
                    });
                  }
                }
              }
              _pixels = pixels;
            }
            if (pixels != 0 && metrics.atEdge) {
              widget.onScrollToMax?.call();
            }
          }
          return true;
        },
      ),
    ];
    if (floating != null) {
      children.add(
        Positioned(
          top: -_offset,
          width: d.maxWidth,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizeListener(
              child: floating!,
              onSizeChange: (size) {
                _size = size;
              },
            ),
          ),
        ),
      );
    }
    return Stack(children: children);
  }
}
