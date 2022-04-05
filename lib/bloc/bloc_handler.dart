import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:codepan/bloc/parent_event.dart';
import 'package:codepan/bloc/parent_state.dart';
import 'package:codepan/resources/strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin BlocHandlerMixin<E extends ParentEvent, S extends ParentState>
    on Bloc<E, S> {
  final Map<Type, bool> _map = {};

  bool isLoading<S>() {
    return _map[S] ?? false;
  }

  void _setLoading(Type key, bool value) {
    _map[key] = value;
  }

  @override
  void onTransition(Transition<E, S> transition) {
    final nextState = transition.nextState;
    if (nextState is FinisherState) {
      final state = nextState as FinisherState;
      _setLoading(state.type, true);
    } else if (nextState is ErrorState) {
      final state = nextState as ErrorState;
      final key = state.type;
      if (_map.containsKey(key)) {
        _map.remove(key);
      }
    } else {
      final key = nextState.runtimeType;
      if (_map.containsKey(key)) {
        _map.remove(key);
      }
    }
    super.onTransition(transition);
  }
}

/// S - The finishing state to complete the loading status
mixin FinisherState<S extends ParentState> {
  Type get type => S;
}

/// S - The finishing state to stop the loading status
mixin ErrorState<S extends ParentState> {
  Type get type => S;

  Object get error;

  bool get isNetwork => error is SocketException;

  String get message {
    if (isNetwork) {
      return Errors.unableToConnectToServer;
    } else if (error is TimeoutException) {
      return Errors.requestTimedOut;
    } else if (error is String) {
      return error.toString();
    }
    return Errors.somethingWentWrong;
  }
}
