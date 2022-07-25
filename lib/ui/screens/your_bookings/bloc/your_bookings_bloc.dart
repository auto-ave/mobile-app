import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/booking_list_model.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'your_bookings_event.dart';
part 'your_bookings_state.dart';

class YourBookingsBloc extends Bloc<YourBookingsEvent, YourBookingsState> {
  Repository _repository;
  YourBookingsBloc({required Repository repository})
      : _repository = repository,
        super(YourBookingsInitial()) {
    on<YourBookingsEvent>((event, emit) async {
      if (event is GetYourBookings) {
        await _mapGetYourBookingToState(
            offset: event.offset, forLoadMore: event.forLoadMore, emit: emit);
      }
    });
  }

  // @override
  // Stream<YourBookingsState> mapEventToState(
  //   YourBookingsEvent event,
  // ) async* {
  //   if (event is GetYourBookings) {
  //     yield* _mapGetYourBookingToState(
  //         offset: event.offset, forLoadMore: event.forLoadMore);
  //   }
  // }

  bool hasReachedMax(YourBookingsState state, bool forLoadMore) =>
      state is YourBookingsLoaded && state.hasReachedMax && forLoadMore;

  FutureOr<void> _mapGetYourBookingToState(
      {required int offset,
      required bool forLoadMore,
      required Emitter<YourBookingsState> emit}) async {
    if (!hasReachedMax(state, forLoadMore)) {
      print("hellobook");
      try {
        List<BookingListModel> bookings = [];
        if (state is YourBookingsLoaded && forLoadMore) {
          emit(MoreYourBookingsLoading());
          bookings = (state as YourBookingsLoaded).bookings;
        } else {
          emit(YourBookingsLoading());
        }

        List<BookingListModel> moreBookings =
            await _repository.getYourBookings(offset: offset);
        emit(YourBookingsLoaded(
            bookings: bookings + moreBookings,
            hasReachedMax:
                moreBookings.length != 10)); //page limit in apiconstants is 10
      } catch (e) {
        emit(YourBookingsError(message: e.toString()));
      }
    }
  }
}
