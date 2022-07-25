import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/vehicle_brand.dart';
import 'package:themotorwash/data/models/vehicle_wheel.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'vehicle_type_list_event.dart';
part 'vehicle_type_list_state.dart';

class VehicleListBloc extends Bloc<VehicleListEvent, VehicleListState> {
  final Repository _repository;
  VehicleListBloc({required Repository repository})
      : _repository = repository,
        super(VehicleListInitial()) {
    on<VehicleListEvent>((event, emit) async {
      if (event is LoadVehicleWheelList) {
        await _mapLoadVehicleWheelListToState(emit: emit);
      } else if (event is LoadVehicleBrandList) {
        await _mapLoadVehicleBrandListToState(
            wheelCode: event.wheelCode, emit: emit);
      } else if (event is LoadVehicleModelList) {
        await _mapLoadVehicleModelListToState(brand: event.brand, emit: emit);
      }
    });
  }

  // @override
  // Stream<VehicleListState> mapEventToState(
  //   VehicleListEvent event,
  // ) async* {
  //   // if (event is LoadVehicleTypeList) {
  //   //   yield* _mapLoadVehicleTypeListToState();
  //   // } else
  // if (event is LoadVehicleWheelList) {
  //   yield* _mapLoadVehicleWheelListToState();
  // } else if (event is LoadVehicleBrandList) {
  //   yield* _mapLoadVehicleBrandListToState(wheelCode: event.wheelCode);
  // } else if (event is LoadVehicleModelList) {
  //   yield* _mapLoadVehicleModelListToState(brand: event.brand);
  // }
  // }

  // Stream<VehicleTypeListState> _mapLoadVehicleTypeListToState() async* {
  //   try {
  //     yield LoadingVehicleTypeList();
  //     List<VehicleTypeModel> vehicleTypes =
  //         await _repository.getVehicleTypeList();
  //     var isAddedMap = HashMap();
  //     List<VehicleWheel> wheels = [];
  //     vehicleTypes.forEach((element) {
  //       if (!isAddedMap.containsKey(element.wheel)) {
  //         isAddedMap.putIfAbsent(element.wheel, () => null);
  //         wheels.add(
  //             VehicleWheel(wheel: element.wheel, imageUrl: element.image!));
  //       }
  //     });

  //     yield VehicleTypeListLoaded(wheels: wheels, vehicleTypes: vehicleTypes);
  //   } catch (e) {
  //     yield FailedToLoadVehicleList(message: e.toString());
  //   }
  // }

  FutureOr<void> _mapLoadVehicleWheelListToState(
      {required Emitter<VehicleListState> emit}) async {
    try {
      emit(VehicleListLoading());
      var vehicleWheels = await _repository.getVehicleWheelList();
      emit(VehicleWheelListLoaded(wheels: vehicleWheels));
    } catch (e) {
      emit(VehicleListError(message: e.toString()));
    }
  }

  FutureOr<void> _mapLoadVehicleBrandListToState(
      {required String wheelCode,
      required Emitter<VehicleListState> emit}) async {
    try {
      emit(VehicleListLoading());
      var vehicleBrands =
          await _repository.getVehicleBrandlList(wheelCode: wheelCode);
      emit(VehicleBrandListLoaded(brands: vehicleBrands));
    } catch (e) {
      emit(VehicleListError(message: e.toString()));
    }
  }

  FutureOr<void> _mapLoadVehicleModelListToState(
      {required String brand, required Emitter<VehicleListState> emit}) async {
    try {
      emit(VehicleListLoading());
      var vehicleModels = await _repository.getVehicleModelList(brand: brand);
      emit(VehicleModelListLoaded(vehicles: vehicleModels));
    } catch (e) {
      emit(VehicleListError(message: e.toString()));
    }
  }
}
