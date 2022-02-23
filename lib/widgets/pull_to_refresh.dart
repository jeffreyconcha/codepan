import 'package:codepan/resources/dimensions.dart';
import 'package:codepan/widgets/size_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatefulWidget {
  final Widget? header, loading, placeholder, floating;
  final VoidCallback? onRefresh, onLoading;
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
    this.floating,
  }) : super(key: key);

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh> {
  double _offset = 0;
  double _pixels = 0;
  Size? _size;

  Widget? get floating => widget.floating;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = Dimension.of(context);
    return Stack(
      children: [
        NotificationListener(
          child: SmartRefresher(
            header: widget.header,
            controller: widget.controller,
            enablePullDown: widget.enablePullDown,
            child: widget.isLoading && widget.itemCount == 0
                ? widget.loading ?? widget.child
                : widget.itemCount == 0
                    ? widget.placeholder ?? widget.child
                    : widget.child,
            physics: widget.isLoading && widget.itemCount != 0
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
                    if (widget.controller.isRefresh) {
                      _offset += delta;
                    } else {
                      _offset = pixels;
                    }
                  });
                } else {
                  final height = _size?.height ?? 0;
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
              }
              _pixels = pixels;
            }
            return true;
          },
        ),
        Builder(builder: (context) {
          if (floating != null) {
            return Positioned(
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
            );
          }
          return Container();
        }),
      ],
    );
  }
}
