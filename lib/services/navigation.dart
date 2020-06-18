import 'package:flutter/cupertino.dart';

class NavigationService {
  static final NavigationService _service = NavigationService._internal();
  final key = GlobalKey<NavigatorState>();

  NavigationService._internal();

  NavigatorState get state => key.currentState;

  factory NavigationService() {
    return _service;
  }

  Future<dynamic> push(Route route) {
    return state.push(route);
  }

  void pop() {
    state.pop();
  }
}
