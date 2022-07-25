import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:themotorwash/blocs/cart/cart_function_bloc.dart';
import 'package:themotorwash/data/local/local_data_service.dart';
import 'package:themotorwash/data/models/auth_tokens.dart';

part 'global_auth_event.dart';
part 'global_auth_state.dart';

class GlobalAuthBloc extends Bloc<GlobalAuthEvent, GlobalAuthState> {
  GlobalAuthBloc() : super(GlobalAuthInitial()) {
    on<GlobalAuthEvent>((event, emit) async {
      if (event is AppStarted || event is CheckAuthStatus) {
        await _mapAppStartedtoState(emit: emit);
      } else if (event is YieldAuthenticatedState) {
        await _mapYieldAuthenticatedStateToState(
            tokens: event.tokens, emit: emit);
      }
    });
  }

  // @override
  // Stream<GlobalAuthState> mapEventToState(
  //   GlobalAuthEvent event,
  // ) async* {
  // if (event is AppStarted || event is CheckAuthStatus) {
  //   yield* _mapAppStartedtoState();
  // } else if (event is YieldAuthenticatedState) {
  //   yield* _mapYieldAuthenticatedStateToState(tokens: event.tokens);
  // }
  // }

  FutureOr<void> _mapAppStartedtoState(
      {required Emitter<GlobalAuthState> emit}) async {
    try {
      emit(CheckingAuthStatus());
      AuthTokensModel tokens = await LocalDataService().getAuthTokens();
      if (tokens.authenticated) {
        emit(Authenticated(tokens: tokens));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(GlobalAuthError(message: e.toString()));
    }
  }

  FutureOr<void> _mapYieldAuthenticatedStateToState(
      {required AuthTokensModel tokens,
      required Emitter<GlobalAuthState> emit}) async {
    emit(Authenticated(tokens: tokens));
  }
}
