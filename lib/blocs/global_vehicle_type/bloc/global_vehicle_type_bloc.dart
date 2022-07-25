import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/local/local_data_service.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';

part 'global_vehicle_type_event.dart';
part 'global_vehicle_type_state.dart';

class GlobalVehicleTypeBloc
    extends Bloc<GlobalVehicleTypeEvent, GlobalVehicleTypeState> {
  final LocalDataService _localDataService;
  GlobalVehicleTypeBloc({required LocalDataService localDataService})
      : _localDataService = localDataService,
        super(GlobalVehicleTypeInitial()) {
    on<GlobalVehicleTypeEvent>((event, emit) async {
      if (event is CheckSavedVehicleType) {
        await _mapCheckSelectedVehicleTypeToState(emit: emit);
      } else if (event is YieldSelectedVehicleType) {
        await _mapYieldSelectedVehicleTypeToState(
            vehicleTypeModel: event.vehicleType, emit: emit);
      }
    });
  }

  // @override
  // Stream<GlobalVehicleTypeState> mapEventToState(
  //   GlobalVehicleTypeEvent event,
  // ) async* {
  // if (event is CheckSavedVehicleType) {
  //   yield* _mapCheckSelectedVehicleTypeToState();
  // } else if (event is YieldSelectedVehicleType) {
  //   yield* _mapYieldSelectedVehicleTypeToState(
  //       vehicleTypeModel: event.vehicleType);
  // }
  // }

  FutureOr<void> _mapCheckSelectedVehicleTypeToState(
      {required Emitter<GlobalVehicleTypeState> emit}) async {
    try {
      emit(CheckingSavedVehicleType());

      VehicleModel? vehicleTypeSelected =
          await _localDataService.getSavedVehicleType();
      if (vehicleTypeSelected == null) {
        emit(VehicleTypeNotSelected());
      } else {
        emit(GlobalVehicleTypeSelected(vehicleTypeModel: vehicleTypeSelected));
      }
    } catch (e) {
      emit(GlobalVehicleTypeError(message: e.toString()));
    }
  }

  FutureOr<void> _mapYieldSelectedVehicleTypeToState(
      {required VehicleModel vehicleTypeModel,
      required Emitter<GlobalVehicleTypeState> emit}) async {
    emit(GlobalVehicleTypeSelected(vehicleTypeModel: vehicleTypeModel));
  }
}
