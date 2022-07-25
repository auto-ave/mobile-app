import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:meta/meta.dart';
import 'package:themotorwash/blocs/global_location/global_location_bloc.dart';
import 'package:themotorwash/data/models/location_model.dart';
import 'package:themotorwash/data/models/sort_param.dart';
import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/data/models/store_list_model.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/utils/utils.dart';

part 'store_list_event.dart';
part 'store_list_state.dart';

class StoreListBloc extends Bloc<StoreListEvent, StoreListState> {
  Repository _repository;
  GlobalLocationBloc _globalLocationBloc;
  StoreListBloc(
      {required Repository repository,
      required GlobalLocationBloc globalLocationBloc})
      : _repository = repository,
        _globalLocationBloc = globalLocationBloc,
        super(StoreListUninitialized()) {
    on<StoreListEvent>((event, emit) async {
      if (event is LoadNearbyStoreList) {
        await _mapLoadNearbyStoreListToState(
            offset: event.offset, forLoadMore: event.forLoadMore, emit: emit);
      } else if (event is LoadStoreListByService) {
        await _mapLoadStoreListByServiceToState(
            offset: event.offset,
            serviceTag: event.serviceTag,
            forLoadMore: event.forLoadMore,
            emit: emit);
      } else if (event is ChangeSortParam) {
        sortParam = event.sortParam;
        add(LoadStoreListByService(
          offset: 0,
          forLoadMore: false,
          serviceTag: event.serviceTag,
        ));
      }
    });
  }

  SortParam sortParam = Distance();

  // @override
  // Stream<StoreListState> mapEventToState(
  //   StoreListEvent event,
  // ) async* {
  // if (event is LoadNearbyStoreList) {
  //   yield* _mapLoadNearbyStoreListToState(
  //       offset: event.offset, forLoadMore: event.forLoadMore);
  // } else if (event is LoadStoreListByService) {
  //   yield* _mapLoadStoreListByServiceToState(
  //       offset: event.offset,
  //       serviceTag: event.serviceTag,
  //       forLoadMore: event.forLoadMore);
  // } else if (event is ChangeSortParam) {
  //   sortParam = event.sortParam;
  //   add(LoadStoreListByService(
  //       offset: 0, forLoadMore: false, serviceTag: event.serviceTag));
  // }
  // }

  bool hasReachedMax(StoreListState state, bool forLoadMore) =>
      state is StoreListLoaded && state.hasReachedMax && forLoadMore;

  FutureOr<void> _mapLoadNearbyStoreListToState(
      {required int offset,
      required bool forLoadMore,
      required Emitter<StoreListState> emit}) async {
    if (!hasReachedMax(state, forLoadMore)) {
      try {
        var locationState = _globalLocationBloc.state as LocationSet;

        List<StoreListModel> stores = [];
        if (state is StoreListLoaded && forLoadMore) {
          stores = (state as StoreListLoaded).stores;
          emit(MoreStoreListLoading());
        } else {
          emit(StoreListLoading());
        }

        List<StoreListModel> moreStores =
            await _repository.getStoreListByLocation(
                locationModel: locationState.location, offset: offset);
        emit(StoreListLoaded(
            stores: stores + moreStores,
            hasReachedMax: moreStores.length != 10)); //Page limit 10
      } catch (e) {
        print('HEllo there crashlytics');
        // await FirebaseCrashlytics.instance.recordError(e, null);
        emit(StoreListError(message: e.toString()));
      }
      // try {
      //   throw Exception(['Hellloo error brother']);
      // } catch (e) {
      //   await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      // }
    }
  }

  FutureOr<void> _mapLoadStoreListByServiceToState(
      {required int offset,
      required String serviceTag,
      required bool forLoadMore,
      required Emitter<StoreListState> emit}) async {
    if (!hasReachedMax(state, forLoadMore)) {
      try {
        var locationState = _globalLocationBloc.state as LocationSet;

        List<StoreListModel> stores = [];
        if (state is StoreListLoaded && forLoadMore) {
          stores = (state as StoreListLoaded).stores;
          emit(MoreStoreListLoading());
        } else {
          emit(StoreListLoading());
        }

        List<StoreListModel> moreStores =
            await _repository.getStoreListByLocation(
                locationModel: locationState.location,
                offset: offset,
                tag: serviceTag,
                sortParam: sortParam);
        emit(StoreListLoaded(
            stores: stores + moreStores,
            hasReachedMax: moreStores.length != 10)); //Page limit 10
      } catch (e) {
        print('HEllo there crashlytics');
        // await FirebaseCrashlytics.instance.recordError(e, null);
        emit(StoreListError(message: e.toString()));
      }
      // try {
      //   throw Exception(['Hellloo error brother']);
      // } catch (e) {
      //   await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      // }
    }
  }
}
