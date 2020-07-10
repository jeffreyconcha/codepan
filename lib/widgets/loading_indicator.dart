import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double width;
  final double height;

  const LoadingIndicator({
    Key key,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }
}
