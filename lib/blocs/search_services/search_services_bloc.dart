import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/price_time_list_model.dart';
import 'package:themotorwash/data/models/service.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'search_services_event.dart';
part 'search_services_state.dart';

class SearchServicesBloc
    extends Bloc<SearchServicesEvent, SearchServicesState> {
  final Repository _repository;
  SearchServicesBloc({required Repository repository})
      : _repository = repository,
        super(SearchServicesUninitialized()) {
    on<SearchServicesEvent>((event, emit) async {
      if (event is SearchServices) {
        await _mapSearchServiceToState(
            forLoadMore: event.forLoadMore,
            query: event.query,
            offset: event.offset,
            pageLimit: event.pageLimit,
            emit: emit);
      }
      if (event is YieldUninitializedState) {
        await _mapYieldUninitializedStateToState(emit: emit);
      }
    }, transformer: debounceTransformer());
    // on<YieldUninitializedState>(
    //     (event, emit) => _mapYieldUninitializedStateToState(emit: emit));
  }

  EventTransformer<SearchServicesEvent> debounceTransformer() {
    return (events, mapper) => events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(mapper);
  }

  // @override
  // Stream<SearchServicesState> mapEventToState(
  //   SearchServicesEvent event,
  // ) async* {
  // if (event is SearchServices) {
  //   yield* _mapSearchServiceToState(
  //       forLoadMore: event.forLoadMore,
  //       query: event.query,
  //       offset: event.offset,
  //       pageLimit: event.pageLimit);
  // }
  // if (event is YieldUninitializedState) {
  //   yield* _mapYieldUninitializedStateToState();
  // }
  // }

  bool hasReachedMax(SearchServicesState state, bool forLoadMore) =>
      state is SearchedServicesResult && state.hasReachedMax && forLoadMore;

  FutureOr<void> _mapSearchServiceToState(
      {required String query,
      required bool forLoadMore,
      required int offset,
      int? pageLimit,
      required Emitter<SearchServicesState> emit}) async {
    if (!hasReachedMax(state, forLoadMore)) {
      try {
        List<ServiceModel> services = [];
        if (state is SearchedServicesResult && forLoadMore) {
          emit(LoadingMoreSearchServicesResult());
          services = (state as SearchedServicesResult).searchedServices;
        } else {
          emit(LoadingSearchServicesResult());
        }
        List<ServiceModel> moreServices = await _repository.searchServices(
            query: query, offset: offset, pageLimit: pageLimit);
        emit(SearchedServicesResult(
            searchedServices: services + moreServices,
            hasReachedMax: moreServices.length != 10));
      } catch (e) {
        emit(SearchedServicesError(message: e.toString()));
      }
    }
  }

  FutureOr<void> _mapYieldUninitializedStateToState(
      {required Emitter<SearchServicesState> emit}) async {
    emit(SearchServicesUninitialized());
  }
}
