import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/cart.dart';
import 'package:themotorwash/data/models/multi_day_slot.dart';
import 'package:themotorwash/data/models/multi_day_slot_detail.dart';
import 'package:themotorwash/data/models/slot.dart';
import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';

part 'order_review_event.dart';
part 'order_review_state.dart';

class OrderReviewBloc extends Bloc<OrderReviewEvent, OrderReviewState> {
  CartModel? cart;
  Slot? slot;
  MultiDaySlot? multiDaySlot;
  OrderReviewBloc() : super(OrderReviewInitial()) {
    on<OrderReviewEvent>((event, emit) {
      if (event is SetCart) {
        cart = event.cart;
        //
      } else if (event is SetSlot) {
        slot = event.slot;
        multiDaySlot = event.multiDaySlot;
        emit(LocalOrderRetrieved(
          slot: slot,
          cart: cart!,
          multiDaySlot: multiDaySlot,
        ));
      }
    });
  }

  // @override
  // Stream<OrderReviewState> mapEventToState(
  //   OrderReviewEvent event,
  // ) async* {
  // if (event is SetCart) {
  //   cart = event.cart;
  //   //
  // } else if (event is SetSlot) {
  //   slot = event.slot;
  //   multiDaySlot = event.multiDaySlot;
  //   yield LocalOrderRetrieved(
  //     slot: slot,
  //     cart: cart!,
  //     multiDaySlot: multiDaySlot,
  //   );
  // }
  // }
}
