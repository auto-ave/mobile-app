import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/direct_booking_response.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'direct_booking_event.dart';
part 'direct_booking_state.dart';

class DirectBookingBloc extends Bloc<DirectBookingEvent, DirectBookingState> {
  Repository _repository;
  DirectBookingBloc({required Repository repository})
      : _repository = repository,
        super(DirectBookingInitial()) {
    on<DirectBookingEvent>((event, emit) async {
      if (event is DirectBookSlot) {
        await _mapDirectBookSlotToState(
            date: event.date,
            bay: event.bay,
            slotStart: event.slotStart,
            slotEnd: event.slotEnd,
            emit: emit);
      }
    });
  }
  FutureOr<void> _mapDirectBookSlotToState(
      {required String date,
      required int? bay,
      required String slotStart,
      required String? slotEnd,
      required Emitter<DirectBookingState> emit}) async {
    try {
      emit(DirectBookingLoading());
      DirectBookingResponse directBookingResponse =
          await _repository.directBookSlot(
              date: date, bay: bay, slotStart: slotStart, slotEnd: slotEnd);
      emit(DirectBookingSuccessful(
          directBookingResponse: directBookingResponse));
    } catch (e) {
      emit(DirectBookingError(message: e.toString()));
    }
  }
}
