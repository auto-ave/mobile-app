part of 'direct_booking_bloc.dart';

abstract class DirectBookingEvent extends Equatable {
  const DirectBookingEvent();
}

class DirectBookSlot extends DirectBookingEvent {
  final String slotStart;
  final String? slotEnd;
  final int? bay;
  final String date;
  DirectBookSlot({
    required this.slotStart,
    this.slotEnd,
    this.bay,
    required this.date,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
