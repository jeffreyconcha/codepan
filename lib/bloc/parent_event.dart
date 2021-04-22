import 'package:codepan/bloc/parent_state.dart';
import 'package:equatable/equatable.dart';

class ParentEvent extends Equatable {
  final ParentState? state;

  const ParentEvent(this.state);

  bool isMirroredFrom<State extends ParentState>() {
    return state is State;
  }

  @override
  List<Object?> get props {
    return [state];
  }
}
