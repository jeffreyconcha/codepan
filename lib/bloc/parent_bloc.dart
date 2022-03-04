import 'package:codepan/bloc/parent_event.dart';
import 'package:codepan/bloc/parent_state.dart';
import 'package:codepan/utils/codepan_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ParentBloc<Event extends ParentEvent, State extends ParentState>
    extends Bloc<Event, State> {
  final Event? initialEvent;

  ParentBloc({
    required State initialState,
    this.initialEvent,
  }) : super(initialState);

  void start() {
    if (initialEvent != null) {
      add(initialEvent!);
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    printError(error, stackTrace);
  }

  void addAll(List<Event> events) {
    events.forEach((event) {
      add(event);
    });
  }
}
