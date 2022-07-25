import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:themotorwash/blocs/global_auth/global_auth_bloc.dart';
import 'package:themotorwash/data/local/local_data_service.dart';
import 'package:themotorwash/data/models/auth_tokens.dart';
import 'package:themotorwash/data/models/send_otp_response.dart';
import 'package:themotorwash/data/repos/auth_repository.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/utils/utils.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  AuthRepository _repository;
  GlobalAuthBloc _globalAuthBloc;
  FirebaseMessaging _fcmInstance;
  LocalDataService _localDataService;
  PhoneAuthBloc(
      {required AuthRepository repository,
      required GlobalAuthBloc globalAuthBloc,
      required FirebaseMessaging fcmInstance,
      required LocalDataService localDataService})
      : _repository = repository,
        _globalAuthBloc = globalAuthBloc,
        _fcmInstance = fcmInstance,
        _localDataService = localDataService,
        super(PhoneAuthUninitialized()) {
    on<PhoneAuthEvent>((event, emit) async {
      if (event is SendOTP) {
        await _mapSendOTPtoState(phoneNumber: event.phoneNumber, emit: emit);
      } else if (event is CheckOTP) {
        await _mapCheckOTPtoState(
            otp: event.otp, phoneNumber: event.phoneNumber, emit: emit);
      } else if (event is LogOut) {
        await _mapLogOutToState(emit: emit);
      }
    });
  }

  // @override
  // Stream<PhoneAuthState> mapEventToState(
  //   PhoneAuthEvent event,
  // ) async* {
  // if (event is SendOTP) {
  //   yield* _mapSendOTPtoState(
  //     phoneNumber: event.phoneNumber,
  //   );
  // } else if (event is CheckOTP) {
  //   yield* _mapCheckOTPtoState(
  //       otp: event.otp, phoneNumber: event.phoneNumber);
  // } else if (event is LogOut) {
  //   yield* _mapLogOutToState();
  // }
  // }

  FutureOr<void> _mapSendOTPtoState(
      {required String phoneNumber,
      required Emitter<PhoneAuthState> emit}) async {
    try {
      emit(SendingOTP());
      SendOTPResponse otpSent =
          await _repository.sendOTP(phoneNumber: phoneNumber);
      otpSent.isOTPSent
          ? emit(OTPSent())
          : emit(FailedToSendOTP(message: otpSent.message!));
    } catch (e) {
      emit(FailedToSendOTP(message: e.toString()));
    }
  }

  FutureOr<void> _mapCheckOTPtoState(
      {required String otp,
      required String phoneNumber,
      required Emitter<PhoneAuthState> emit}) async {
    try {
      emit(CheckingOTP());
      print('checking otp');
      String? token = await _fcmInstance.getToken();
      //TODO

      AuthTokensModel tokens = await _repository.checkOTP(
          phoneNumber: phoneNumber, otp: otp, token: token ?? '');

      await _localDataService.storeAuthToken(tokens);

      tokens.authenticated
          ? emit(OTPCheckedPassed(tokens: tokens))
          : emit(OTPCheckFailed(message: 'Wrong OTP entered'));

      if (tokens.authenticated) {
        try {
          // mixpanel?.identify(
          //   phoneNumber,
          // );

          await FlutterUxcam.setUserIdentity(phoneNumber);
        } on Exception catch (e) {
          autoaveLog(e.toString());
        }

        _globalAuthBloc.add(YieldAuthenticatedState(tokens: tokens));
      }
    } catch (e) {
      emit(OTPCheckFailed(message: e.toString()));
    }
  }

  FutureOr<void> _mapLogOutToState(
      {required Emitter<PhoneAuthState> emit}) async {
    try {
      String? token = await _fcmInstance.getToken();
      print('FCM TOKEN' + token.toString());
      if (token != null) {
        await _repository.logout(token: token);
      }
    } catch (e) {
      print(e.toString());
    }
    try {
      await _localDataService.removeTokens();
      _globalAuthBloc.add(CheckAuthStatus());
    } catch (e) {}
  }
}
