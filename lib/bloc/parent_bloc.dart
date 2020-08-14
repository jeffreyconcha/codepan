import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ParentBloc<Event, State> extends Bloc<Event, State> {
  ParentBloc({
    Event initialEvent,
    State initialState,
  }) : super(initialState) {
    this.add(initialEvent);
  }
}
