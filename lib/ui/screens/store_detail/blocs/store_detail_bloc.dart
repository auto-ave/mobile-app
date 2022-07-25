import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'store_detail_event.dart';
part 'store_detail_state.dart';

class StoreDetailBloc extends Bloc<StoreDetailEvent, StoreDetailState> {
  final Repository _repository;
  StoreDetailBloc({required Repository repository})
      : _repository = repository,
        super(StoreDetailInitial()) {
    on<StoreDetailEvent>((event, emit) async {
      if (event is LoadStoreDetail) {
        await _mapGetStoreDetailPressedToState(
            storeSlug: event.storeSlug, emit: emit);
      }
    });
  }

  // @override
  // Stream<StoreDetailState> mapEventToState(
  //   StoreDetailEvent event,
  // ) async* {
  //   if (event is LoadStoreDetail) {
  //     yield* _mapGetStoreDetailPressedToState(event.storeSlug);
  //   }
  // }

  FutureOr<void> _mapGetStoreDetailPressedToState(
      {required String storeSlug,
      required Emitter<StoreDetailState> emit}) async {
    try {
      emit(StoreDetailLoading());
      Store store = await _repository.getStoreDetailBySlug(slug: storeSlug);
      emit(StoreDetailLoaded(store: store));
    } catch (e) {
      emit(StoreDetailError(message: e.toString()));
    }
  }
}
