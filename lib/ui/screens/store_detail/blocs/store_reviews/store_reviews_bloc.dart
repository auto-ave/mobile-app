import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/review.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'store_reviews_event.dart';
part 'store_reviews_state.dart';

class StoreReviewsBloc extends Bloc<StoreReviewsEvent, StoreReviewsState> {
  final Repository _repository;
  StoreReviewsBloc({required Repository repository})
      : _repository = repository,
        super(StoreReviewsInitial()) {
    on<StoreReviewsEvent>((event, emit) async {
      if (event is LoadStoreReviews) {
        await _mapLoadStoreReviewsToState(
            slug: event.slug,
            offset: event.offset,
            forLoadMore: event.forLoadMore,
            emit: emit);
      }
    });
  }
  // @override
  // Stream<StoreReviewsState> mapEventToState(
  //   StoreReviewsEvent event,
  // ) async* {
  // if (event is LoadStoreReviews) {
  //   yield* _mapLoadStoreReviewsToState(
  //       slug: event.slug,
  //       offset: event.offset,
  //       forLoadMore: event.forLoadMore);
  // }
  // }

  bool hasReachedMax(StoreReviewsState state) =>
      state is StoreReviewsLoaded && state.hasReachedMax;

  FutureOr<void> _mapLoadStoreReviewsToState(
      {required String slug,
      required int offset,
      required bool forLoadMore,
      required Emitter<StoreReviewsState> emit}) async {
    if (!hasReachedMax(state)) {
      try {
        List<Review> reviews = [];
        if (state is StoreReviewsLoaded && forLoadMore) {
          reviews = (state as StoreReviewsLoaded).reviews;
          emit(MoreStoreReviewsLoading());
        } else {
          emit(StoreReviewsLoading());
        }

        List<Review> moreReviews =
            await _repository.getStoreReviewsBySlug(slug: slug, offset: offset);
        emit(StoreReviewsLoaded(
            reviews: reviews + moreReviews,
            hasReachedMax: moreReviews.length !=
                10)); // Page Limit set in apiconstants is 10. Therefore if services retured are less than 10, then hasReachedMax is true
      } catch (e) {
        emit(StoreReviewsError(message: e.toString()));
      }
    }
  }
}
