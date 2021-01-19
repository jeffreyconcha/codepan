import 'package:codepan/bloc/parent_event.dart';
import 'package:equatable/equatable.dart';

abstract class ParentState<Event extends ParentEvent> extends Equatable {
  const ParentState();

  Event mirrorToEvent();
}

class StateOrigin<Event extends ParentEvent> {
  Type get origin => Event;
}
