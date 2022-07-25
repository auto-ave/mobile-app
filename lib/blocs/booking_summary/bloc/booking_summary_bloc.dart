import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/booking_detail.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/utils/utils.dart';

part 'booking_summary_event.dart';
part 'booking_summary_state.dart';

class BookingSummaryBloc
    extends Bloc<BookingSummaryEvent, BookingSummaryState> {
  final Repository _repository;
  BookingSummaryBloc({required Repository repository})
      : _repository = repository,
        super(BookingSummaryInitial()) {
    on<BookingSummaryEvent>((event, emit) async {
      if (event is GetBookingSummary) {
        await _mapGetBookingSummaryToState(
            bookingId: event.bookingId, emit: emit);
      }
    });
  }

  // @override
  // Stream<BookingSummaryState> mapEventToState(
  //   BookingSummaryEvent event,
  // ) async* {
  //   if (event is GetBookingSummary) {
  //     yield* _mapGetBookingSummaryTostate(bookingId: event.bookingId);
  //   }
  //

  Future<void> _mapGetBookingSummaryToState(
      {required String bookingId,
      required Emitter<BookingSummaryState> emit}) async {
    try {
      autoaveLog("This calls this");
      emit(BookingSummaryLoading());
      BookingDetailModel booking =
          await _repository.getBookingDetail(bookingId: bookingId);
      emit(BookingSummaryLoaded(booking: booking));
    } catch (e) {
      emit(BookingSummaryError(message: e.toString()));
    }
  }
}
