import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/size_listener.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatefulWidget {
  final WidgetBuilder? loadingBuilder, placeholderBuilder, errorBuilder;
  final VoidCallback? onRefresh, onLoading, onScrollToMax;
  final bool isLoading, isError, enablePullDown;
  final RefreshController controller;
  final Widget? header, floating;
  final WidgetBuilder builder;
  final int? itemCount;
  final bool? isCompleted;
  final ScrollPhysics? physics;

  const PullToRefresh({
    super.key,
    required this.controller,
    required this.builder,
    this.placeholderBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.header,
    this.isCompleted,
    this.isLoading = false,
    this.isError = false,
    this.enablePullDown = true,
    this.itemCount,
    this.onRefresh,
    this.onLoading,
    this.onScrollToMax,
    this.floating,
    this.physics,
  });

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh> {
  late bool _isError;
  double _offset = 0;
  double _pixels = 0;
  Size? _size;

  RefreshController get controller => widget.controller;

  Widget? get floating => widget.floating;

  double get height => _size?.height ?? 0;

  ScrollPhysics? get physics => widget.physics;

  @override
  void initState() {
    super.initState();
    _isError = widget.isError;
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    final children = <Widget>[
      NotificationListener(
        child: SmartRefresher(
          header: widget.header,
          controller: controller,
          enablePullDown: widget.enablePullDown,
          child: _buildChild(context),
          physics: controller.isRefresh ? NeverScrollableScrollPhysics() : physics,
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
              onSizeChange: (size, offset) {
                _size = size;
              },
            ),
          ),
        ),
      );
    }
    return Stack(children: children);
  }

  Widget _buildChild(BuildContext context) {
    final child = widget.builder(context);
    if ((widget.isLoading && !controller.isRefresh) ||
        (controller.isRefresh && _isError)) {
      return widget.loadingBuilder?.call(context) ?? child;
    } else {
      if (widget.isError) {
        _isError = true;
        return widget.errorBuilder?.call(context) ?? child;
      } else {
        if (widget.itemCount == 0 && (widget.isCompleted ?? true)) {
          return widget.placeholderBuilder?.call(context) ?? child;
        }
      }
    }
    _isError = false;
    return child;
  }
}
