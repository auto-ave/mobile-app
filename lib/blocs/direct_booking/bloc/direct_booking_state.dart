part of 'direct_booking_bloc.dart';

abstract class DirectBookingState extends Equatable {
  const DirectBookingState();
}

class DirectBookingInitial extends DirectBookingState {
  @override
  List<Object> get props => [];
}

class DirectBookingSuccessful extends DirectBookingState {
  final DirectBookingResponse directBookingResponse;
  DirectBookingSuccessful({
    required this.directBookingResponse,
  });
  @override
  List<Object> get props => [directBookingResponse];
}

class DirectBookingError extends DirectBookingState {
  final String message;
  DirectBookingError({
    required this.message,
  });
  @override
  List<Object> get props => [];
}

class DirectBookingLoading extends DirectBookingState {
  @override
  List<Object> get props => [];
}
