import 'package:codepan/bloc/parent_bloc.dart';
import 'package:codepan/transitions/route_transition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension BuildContextUtils on BuildContext {
  void popAllRoutes() {
    final navigator = Navigator.of(this);
    while (navigator.canPop()) {
      navigator.pop();
    }
  }

  void pop<T>([T? result]) {
    Navigator.of(this).pop(result);
  }

  void popUntil(RoutePredicate predicate) {
    Navigator.of(this).popUntil(predicate);
  }

  Future<dynamic> push({
    required Widget page,
  }) {
    return Navigator.of(this).push(
      CupertinoPageRoute(
        builder: (context) {
          return page;
        },
      ),
    );
  }

  Future<dynamic> replace({
    required Widget page,
    Duration? duration,
  }) {
    return Navigator.of(this).pushReplacement(
      FadeRoute(
        enter: page,
        duration: duration,
      ),
    );
  }

  Future<dynamic> fadeIn({
    required Widget page,
    Duration? duration,
  }) {
    return Navigator.of(this).push(
      FadeRoute(
        enter: page,
        duration: duration,
      ),
    );
  }

  Future<dynamic> slideToTop({
    required Widget page,
    Duration? duration,
  }) {
    return Navigator.of(this).push(
      BottomModalRoute(
        enter: page,
        duration: duration,
      ),
    );
  }

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }

  T blocOf<T extends ParentBloc>() {
    return BlocProvider.of<T>(this);
  }
}
