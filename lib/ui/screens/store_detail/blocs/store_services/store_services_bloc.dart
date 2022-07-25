import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/price_time_list_model.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'store_services_event.dart';
part 'store_services_state.dart';

class StoreServicesBloc extends Bloc<StoreServicesEvent, StoreServicesState> {
  final Repository _repository;
  StoreServicesBloc({required Repository repository})
      : _repository = repository,
        super(StoreServicesInitial()) {
    on<StoreServicesEvent>((event, emit) async {
      if (event is LoadStoreServices) {
        await _mapLoadStoreServicesToState(
            slug: event.slug,
            vehicleType: event.vehicleType,
            offset: event.offset,
            forLoadMore: event.forLoadMore,
            firstServiceTag: event.firstServiceTag,
            emit: emit);
      }
    });
  }
  // @override
  // Stream<StoreServicesState> mapEventToState(
  //   StoreServicesEvent event,
  // ) async* {
  // if (event is LoadStoreServices) {
  //   yield* _mapLoadStoreServicesToState(
  //       slug: event.slug,
  //       vehicleType: event.vehicleType,
  //       offset: event.offset,
  //       forLoadMore: event.forLoadMore,
  //       firstServiceTag: event.firstServiceTag);
  // }
  // }

  bool hasReachedMax(StoreServicesState state, bool forLoadMore) =>
      state is StoreServicesLoaded && state.hasReachedMax && forLoadMore;

  FutureOr<void> _mapLoadStoreServicesToState(
      {required String slug,
      required String vehicleType,
      required int offset,
      required bool forLoadMore,
      String? firstServiceTag,
      required Emitter<StoreServicesState> emit}) async {
    if (!hasReachedMax(state, forLoadMore)) {
      try {
        List<PriceTimeListModel> services = [];

        if (state is StoreServicesLoaded && forLoadMore) {
          services = (state as StoreServicesLoaded).services;
          emit(MoreStoreServicesLoading());
        } else {
          emit(StoreServicesLoading());
        }
        List<PriceTimeListModel> moreServices =
            await _repository.getStoreServicesBySlugAndVehicleType(
                slug: slug,
                vehicleType: vehicleType,
                offset: offset,
                firstServiceTag: firstServiceTag);
        emit(StoreServicesLoaded(
            vehicleType: vehicleType,
            services: services + moreServices,
            hasReachedMax: moreServices.length !=
                10)); // Page Limit set in apiconstants is 10. Therefore if services retured are less than 10, then hasReachedMax is true
      } catch (e) {
        emit(StoreServicesError(message: e.toString()));
      }
    }
  }
}
