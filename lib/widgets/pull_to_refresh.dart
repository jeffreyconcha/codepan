import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefresh extends StatelessWidget {
  final VoidCallback? onRefresh, onLoading;
  final RefreshController controller;
  final bool isLoading;
  final Widget? header;
  final Widget child;

  const PullToRefresh({
    Key? key,
    required this.controller,
    required this.child,
    this.header,
    this.isLoading = false,
    this.onRefresh,
    this.onLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      header: header,
      controller: controller,
      child: child,
      physics: isLoading ? NeverScrollableScrollPhysics() : null,
      onRefresh: onRefresh,
      onLoading: onLoading,
    );
  }
}
