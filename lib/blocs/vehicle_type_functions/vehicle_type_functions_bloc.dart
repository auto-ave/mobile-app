import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/blocs/global_vehicle_type/bloc/global_vehicle_type_bloc.dart';
import 'package:themotorwash/data/local/local_data_service.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';

part 'vehicle_type_functions_event.dart';
part 'vehicle_type_functions_state.dart';

class VehicleTypeFunctionsBloc
    extends Bloc<VehicleTypeFunctionsEvent, VehicleTypeFunctionsState> {
  final GlobalVehicleTypeBloc _globalVehicleTypeBloc;
  final LocalDataService _localDataService;
  VehicleTypeFunctionsBloc(
      {required GlobalVehicleTypeBloc globalVehicleTypeBloc,
      required LocalDataService localDataService})
      : _globalVehicleTypeBloc = globalVehicleTypeBloc,
        _localDataService = localDataService,
        super(VehicleTypeFunctionsInitial()) {
    on<VehicleTypeFunctionsEvent>((event, emit) async {
      if (event is SelectVehicleType) {
        await _mapSelectVehicleTypeToState(
            vehicleTypeModel: event.vehicleTypeModel, emit: emit);
      }
    });
  }

  // @override
  // Stream<VehicleTypeFunctionsState> mapEventToState(
  //   VehicleTypeFunctionsEvent event,
  // ) async* {
  // if (event is SelectVehicleType) {
  //   yield* _mapSelectVehicleTypeToState(
  //       vehicleTypeModel: event.vehicleTypeModel);
  // }
  // }

  FutureOr<void> _mapSelectVehicleTypeToState(
      {required VehicleModel vehicleTypeModel,
      required Emitter<VehicleTypeFunctionsState> emit}) async {
    try {
      emit(SelectingVehicleType());
      await _localDataService.saveVehicleType(
          vehicleTypeModel: vehicleTypeModel);
      _globalVehicleTypeBloc
          .add(YieldSelectedVehicleType(vehicleType: vehicleTypeModel));
      emit(VehicleTypeSelectedFunctionsState(
          vehicleTypeModel: vehicleTypeModel));
    } catch (e) {
      emit(FailedToSelectVehicleType(message: e.toString()));
    }
  }
}
