import 'package:flutter/material.dart';

abstract class StateWithLifecycle<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver
    implements LifeCycle {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
        break;
      case AppLifecycleState.paused:
        onPause();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.detached:
        onDetach();
        break;
    }
  }

  @override
  void onResume() {
    debugPrint('resumed');
  }

  @override
  void onPause() {
    debugPrint('paused');
  }

  @override
  void onDetach() {
    debugPrint('detached');
  }

  @override
  void onInactive() {
    debugPrint('inactive');
  }
}

abstract class LifeCycle {
  void onResume();

  void onPause();

  void onDetach();

  void onInactive();
}
