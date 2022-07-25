import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/blocs/global_location/global_location_bloc.dart';
import 'package:themotorwash/data/models/location_model.dart';
import 'package:themotorwash/data/models/store_list_model.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'search_stores_event.dart';
part 'search_stores_state.dart';

class SearchStoresBloc extends Bloc<SearchStoresEvent, SearchStoresState> {
  final Repository _repository;
  final GlobalLocationBloc _globalLocationBloc;
  SearchStoresBloc(
      {required Repository repository,
      required GlobalLocationBloc globalLocationBloc})
      : _repository = repository,
        _globalLocationBloc = globalLocationBloc,
        super(SearchStoresInitial()) {
    on<SearchStoresEvent>((event, emit) async {
      if (event is SearchStores) {
        await _mapSearchStoresToState(
            query: event.query,
            offset: event.offset,
            forLoadMore: event.forLoadMore,
            emit: emit);
      }
    }, transformer: _debounceTransformerSearchStores());
  }

  EventTransformer<SearchStoresEvent> _debounceTransformerSearchStores() {
    return (events, mapper) => events
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap(mapper);
  }

  // @override
  // Stream<SearchStoresState> mapEventToState(
  //   SearchStoresEvent event,
  // ) async* {
  // if (event is SearchStores) {
  //   yield* _mapSearchStoresToState(
  //       query: event.query,
  //       offset: event.offset,
  //       forLoadMore: event.forLoadMore);
  // }
  // }

  bool hasReachedMax(SearchStoresState state, bool forLoadMore) =>
      state is SearchedStoresResult && state.hasReachedMax && forLoadMore;
  FutureOr<void> _mapSearchStoresToState(
      {required String query,
      required int offset,
      required bool forLoadMore,
      required Emitter<SearchStoresState> emit}) async {
    if (!hasReachedMax(state, forLoadMore)) {
      try {
        var locationState = _globalLocationBloc.state as LocationSet;
        List<StoreListModel> stores = [];
        if (state is SearchedStoresResult && forLoadMore) {
          emit(LoadingMoreSearchStoresResult());
          stores = (state as SearchedStoresResult).searchedStores;
        } else {
          emit(LoadingSearchStoresResult());
        }

        List<StoreListModel> moreStores = await _repository.searchStores(
          query: query,
          offset: offset,
          locationModel: locationState.location,
        );
        emit(SearchedStoresResult(
            searchedStores: stores + moreStores,
            hasReachedMax: moreStores.length != 10)); //Page Limit is 10
      } catch (e) {
        emit(SearchedStoresError(message: e.toString()));
      }
    }
  }
}
