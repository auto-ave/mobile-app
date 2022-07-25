import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:themotorwash/blocs/global_cart/bloc/global_cart_bloc.dart';
import 'package:themotorwash/blocs/order_review/order_review_bloc.dart';
import 'package:themotorwash/data/models/cart.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'cart_function_event.dart';
part 'cart_function_state.dart';

class CartFunctionBloc extends Bloc<CartFunctionEvent, CartFunctionState> {
  final Repository _repository;
  final OrderReviewBloc _orderReviewBloc;
  final GlobalCartBloc _globalCartBloc;

  CartFunctionBloc(
      {required Repository repository,
      required OrderReviewBloc orderReviewBloc,
      required GlobalCartBloc globalCartBloc})
      : _repository = repository,
        _orderReviewBloc = orderReviewBloc,
        _globalCartBloc = globalCartBloc,
        super(CartFunctionUninitialized()) {
    on<CartFunctionEvent>((event, emit) async {
      if (event is AddItemToCart) {
        await _mapAddItemToCartToState(
            itemId: event.itemId, vehicleModel: event.vehicleModel, emit: emit);
      } else if (event is DeleteItemFromCart) {
        await _mapDeleteItemFromCart(itemId: event.itemId, emit: emit);
      } else if (event is ClearCart) {
        await _mapClearCartToState(emit: emit);
      } else if (event is GetCart) {
        await _mapGetCartToState(emit: emit);
      } else if (event is ClearLocalCart) {
        await _mapClearLocalCartToState(emit: emit);
      }
    });
  }

  // @override
  // Stream<CartFunctionState> mapEventToState(
  //   CartFunctionEvent event,
  // ) async* {
  //   if (event is AddItemToCart) {
  //     yield* _mapAddItemToCartToState(
  //         itemId: event.itemId, vehicleModel: event.vehicleModel);
  //   } else if (event is DeleteItemFromCart) {
  //     yield* _mapDeleteItemFromCart(itemId: event.itemId);
  //   } else if (event is ClearCart) {
  //     yield* _mapClearCartToState();
  //   } else if (event is GetCart) {
  //     yield* _mapGetCartToState();
  //   } else if (event is ClearLocalCart) {
  //     yield* _mapClearLocalCartToState();
  //   }
  // }

  FutureOr<void> _mapAddItemToCartToState(
      {required int itemId,
      required String vehicleModel,
      required Emitter<CartFunctionState> emit}) async {
    try {
      FirebaseAnalytics.instance.logAddToCart(items: [
        AnalyticsEventItem(
          itemId: itemId.toString(),
          itemName: vehicleModel,
          itemCategory: 'Vehicle',
        )
      ]);
    } catch (e) {
      print(e.toString() + " Analytics");
    }
    try {
      if (state is CartFunctionLoading) {
        var previousItems = (state as CartFunctionLoading).itemId;
        previousItems.add(itemId);
        print(previousItems.toString() + "helolo" + "add");

        emit(CartFunctionLoading(itemId: previousItems));
      } else {
        print("loladdhelolo");

        emit(CartFunctionLoading(itemId: [itemId]));
      }

      CartModel cart = await _repository.postAddItemToCart(
          itemId: itemId, vehicleModel: vehicleModel);
      _orderReviewBloc.add(SetCart(cart: cart));
      _globalCartBloc.add(NewCart(cart: cart));
      emit(CartItemAdded(cart: cart));
    } catch (e) {
      emit(CartStateError(message: e.toString()));
    }
  }

  FutureOr<void> _mapDeleteItemFromCart(
      {required int itemId, required Emitter<CartFunctionState> emit}) async {
    try {
      if (state is CartFunctionLoading) {
        var previousItems = (state as CartFunctionLoading).itemId;
        previousItems.add(itemId);
        // print(previousItems.toString() + "helolo");
        emit(CartFunctionLoading(itemId: previousItems));
      } else {
        // print("lolhelolo");
        emit(CartFunctionLoading(itemId: [itemId]));
      }
      CartModel cart = await _repository.postDeleteItemFromCart(itemId: itemId);
      _globalCartBloc.add(NewCart(cart: cart));
      _orderReviewBloc.add(SetCart(cart: cart));

      emit(CartItemDeleted(cart: cart));
    } catch (e) {
      emit(CartStateError(message: e.toString()));
    }
  }

  FutureOr<void> _mapClearCartToState(
      {required Emitter<CartFunctionState> emit}) async {
    // try {
    //   CartModel cart = await _repository.postAddItemToCart(itemId: itemId);
    //   yield CartItemAdded(cart: cart);
    // } catch (e) {
    //   yield CartStateError(message: e.toString());
    // }
  }

  FutureOr<void> _mapGetCartToState(
      {required Emitter<CartFunctionState> emit}) async {
    try {
      emit(CartLoading());

      CartModel cart = await _repository.getCart();

      _orderReviewBloc.add(SetCart(cart: cart));
      _globalCartBloc.add(NewCart(cart: cart));

      emit(CartLoaded(cart: cart));
    } catch (e) {
      emit(CartStateError(message: e.toString()));
    }
  }

  FutureOr<void> _mapClearLocalCartToState(
      {required Emitter<CartFunctionState> emit}) async {
    emit(CartFunctionUninitialized());
    _globalCartBloc.add(ClearGlobalLocalCart());
  }
}
