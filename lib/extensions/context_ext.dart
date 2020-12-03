import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension BuildContextUtils on BuildContext {
  void popAllRoutes() {
    final navigator = Navigator.of(this);
    while (navigator.canPop()) {
      navigator.pop();
    }
  }

  void pop() {
    Navigator.of(this).pop();
  }

  void push({@required Widget page}) {
    Navigator.of(this).push(
      CupertinoPageRoute(
        builder: (context) {
          return page;
        },
      ),
    );
  }

  void pushReplacement(Route route) {
    Navigator.of(this).pushReplacement(route);
  }

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
