import 'package:codepan/bloc/parent_event.dart';
import 'package:codepan/bloc/parent_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ParentBloc<Event extends ParentEvent, State extends ParentState>
    extends Bloc<Event, State> {
  ParentBloc({
    Event initialEvent,
    State initialState,
  }) : super(initialState) {
    if (initialEvent != null) {
      this.add(initialEvent);
    }
  }
}
