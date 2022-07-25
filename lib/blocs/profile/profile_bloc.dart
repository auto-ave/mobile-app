import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:themotorwash/data/models/user_profile.dart';
import 'package:themotorwash/data/repos/repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final Repository _repository;

  ProfileBloc({required Repository repository})
      : _repository = repository,
        super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) async {
      if (event is GetProfile) {
        await _mapGetProfileToState(emit: emit);
      } else if (event is UpdateProfile) {
        await _mapUpdateProfileToState(
            entity: event.userProfileEntity, emit: emit);
      }
    });
  }

  // @override
  // Stream<ProfileState> mapEventToState(
  //   ProfileEvent event,
  // ) async* {
  // if (event is GetProfile) {
  //   yield* _mapGetProfileToState();
  // } else if (event is UpdateProfile) {
  //   yield* _mapUpdateProfileToState(entity: event.userProfileEntity);
  // }
  // }

  FutureOr<void> _mapGetProfileToState(
      {required Emitter<ProfileState> emit}) async {
    try {
      emit(LoadingProfile());
      UserProfile userProfile = await _repository.getAccountDetails();
      emit(ProfileLoaded(userProfile: userProfile));
    } catch (e) {
      emit(FailedToLoadProfile(message: e.toString()));
    }
  }

  FutureOr<void> _mapUpdateProfileToState(
      {required UserProfileEntity entity,
      required Emitter<ProfileState> emit}) async {
    try {
      emit(UpdatingProfile());
      UserProfile userProfile =
          await _repository.updateAccountDetails(userProfileEntity: entity);
      emit(ProfileUpdated(userProfile: userProfile));
    } catch (e) {
      emit(FailedToLoadProfile(message: e.toString()));
    }
  }
}
