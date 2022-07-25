import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:themotorwash/data/models/fcm_topic.dart';
import 'package:themotorwash/data/repos/auth_repository.dart';
import 'package:themotorwash/data/repos/auth_rest_repository.dart';

part 'fcm_event.dart';
part 'fcm_state.dart';

class FcmBloc extends Bloc<FcmEvent, FcmState> {
  final FirebaseMessaging _fcmInstance;
  final AuthRepository _authRepository;
  FcmBloc(
      {required FirebaseMessaging fcmInstance,
      required AuthRepository authRepository})
      : _fcmInstance = fcmInstance,
        _authRepository = authRepository,
        super(FcmInitial()) {
    on<FcmEvent>((event, emit) async {
      if (event is UpdateDeviceToken) {
        await _mapUpdateDeviceTokenToState(emit: emit);
      } else if (event is RegisterTopics) {
        await _mapRegisterTopicsToState(topics: event.topics, emit: emit);
      } else if (event is SubscribeToTopicsNewLogin) {
        await _mapSubscribeToTopicsNewLoginToState(emit: emit);
      }
    });
  }

  // @override
  // Stream<FcmState> mapEventToState(
  //   FcmEvent event,
  // ) async* {
  //   // TODO: implement mapEventToState
  // if (event is UpdateDeviceToken) {
  //   yield* _mapUpdateDeviceTokenToState();
  // } else if (event is RegisterTopics) {
  //   yield* _mapRegisterTopicsToState(topics:event.topics);
  // } else if (event is SubscribeToTopicsNewLogin) {
  //   yield* _mapSubscribeToTopicsNewLoginToState();
  // }
  // }

  FutureOr<void> _mapUpdateDeviceTokenToState(
      {required Emitter<FcmState> emit}) async {
    try {
      await _fcmInstance.deleteToken();
      String? token = await _fcmInstance.getToken();
      if (token != null) {
        await _authRepository.addFcmToken(token: token);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  FutureOr<void> _mapRegisterTopicsToState(
      {required List<String> topics, required Emitter<FcmState> emit}) async {
    try {
      await _authRepository.subcribeFcmTopics(topics: topics);
    } catch (e) {
      print(e.toString());
    }
  }

  FutureOr<void> _mapSubscribeToTopicsNewLoginToState(
      {required Emitter<FcmState> emit}) async {
    try {
      final List<FcmTopic> registeredTopics =
          await _authRepository.getFcmTopics();
      List<String> topics = registeredTopics.map((e) => e.topic).toList();
      topics.forEach((element) async {
        await _fcmInstance.subscribeToTopic(element);
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
