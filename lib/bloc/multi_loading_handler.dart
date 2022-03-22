import 'package:bloc/bloc.dart';
import 'package:codepan/bloc/parent_bloc.dart';
import 'package:codepan/bloc/parent_event.dart';
import 'package:codepan/bloc/parent_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin MultiLoadingHandlerMixin<E extends ParentEvent, S extends ParentState>
    on ParentBloc<E, S> {
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

mixin ErrorState<S extends ParentState> {
  Type get type => S;
}
