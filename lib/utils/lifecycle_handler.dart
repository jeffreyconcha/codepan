import 'package:flutter/material.dart';

abstract class StateWithLifecycle<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
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
        onNotActive();
        break;
      case AppLifecycleState.detached:
        onDetach();
        break;
    }
  }

  void onResume() => debugPrint('resumed');

  void onPause() => debugPrint('paused');

  void onDetach() => debugPrint('inactive');

  void onNotActive() => debugPrint('detached');
}
