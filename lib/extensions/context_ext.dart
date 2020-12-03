import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension BuildContextUtils on BuildContext {
  void popAllRoutes() {
    final navigator = Navigator.of(this);
    while (navigator.canPop()) {
      navigator.pop();
    }
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

  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}
