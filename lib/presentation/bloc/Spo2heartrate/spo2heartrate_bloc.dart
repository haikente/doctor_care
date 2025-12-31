import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'spo2heartrate_event.dart';
part 'spo2heartrate_state.dart';

class Spo2heartrateBloc extends Bloc<Spo2heartrateEvent, Spo2heartrateState> {
  Spo2heartrateBloc() : super(Spo2heartrateInitial());

  @override
  Stream<Spo2heartrateState> mapEventToState(
    Spo2heartrateEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
