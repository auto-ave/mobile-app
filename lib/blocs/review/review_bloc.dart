import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/review.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final Repository _repository;
  ReviewBloc({required Repository repository})
      : _repository = repository,
        super(ReviewInitial()) {
    on<ReviewEvent>((event, emit) async {
      if (event is GetReview) {
        await _mapGetReviewToState(bookingId: event.bookingId, emit: emit);
      } else if (event is AddReview) {
        await _mapAddReviewToState(reviewEntity: event.review, emit: emit);
      }
    });
  }

  // @override
  // Stream<ReviewState> mapEventToState(
  //   ReviewEvent event,
  // ) async* {
  // if (event is GetReview) {
  //   yield* _mapGetReviewToState(bookingId: event.bookingId);
  // } else if (event is AddReview) {
  //   yield* _mapAddReviewToState(reviewEntity: event.review);
  // }
  // }

  FutureOr<void> _mapGetReviewToState(
      {required String bookingId, required Emitter<ReviewState> emit}) async {
    try {
      // Review review = await _repository.getReview(bookingId: bookingId);
      // yield ReviewLoaded(isReviewed: )
    } catch (e) {}
  }

  FutureOr<void> _mapAddReviewToState(
      {required ReviewEntity reviewEntity,
      required Emitter<ReviewState> emit}) async {
    try {
      emit(AddingReview());
      Review review = await _repository.addReview(review: reviewEntity);
      emit(ReviewAdded(review: review));
    } catch (e) {
      emit(FailedToAddReview(message: e.toString()));
    }
  }
}
