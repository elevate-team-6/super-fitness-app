import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

class BaseCubit<State, UiEvent> extends Cubit<State> {
  BaseCubit(super.initialState);

  final StreamController<UiEvent> _eventController =
      StreamController.broadcast();

  Stream<UiEvent> get eventStream => _eventController.stream;

  void emitUiEvent(UiEvent event) {
    if (_eventController.isClosed) {
      throw Exception('cannot emit new event after closing the stream');
    }
    _eventController.add(event);
  }

  @override
  Future<void> close() {
    _eventController.close();
    return super.close();
  }
}
