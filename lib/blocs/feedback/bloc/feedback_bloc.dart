import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final Repository _repository;
  FeedbackBloc({required Repository repository})
      : _repository = repository,
        super(FeedbackInitial()) {
    on<FeedbackEvent>((event, emit) async {
      if (event is SendFeedback) {
        await _mapSendFeedbackToState(
            email: event.email,
            message: event.message,
            phoneNumber: event.phone,
            emit: emit);
      }
    });
  }

  // @override
  // Stream<FeedbackState> mapEventToState(
  //   FeedbackEvent event,
  // ) async* {
  // if (event is SendFeedback) {
  //   yield* _mapSendFeedbackToState(
  //       email: event.email, message: event.message, phoneNumber: event.phone);
  // }
  // }

  FutureOr<void> _mapSendFeedbackToState(
      {required String phoneNumber,
      required String email,
      required String message,
      required Emitter<FeedbackState> emit}) async {
    try {
      emit(FeedbackLoading());
      await _repository.sendFeedback(
          email: email, phoneNumber: phoneNumber, message: message);
      emit(FeedbackSent());
    } catch (e) {
      emit(FeedbackError(message: e.toString()));
    }
  }
}
