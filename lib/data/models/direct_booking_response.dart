import 'package:json_annotation/json_annotation.dart';
part 'direct_booking_response.g.dart';

class DirectBookingResponse {
  final String bookingId;

  DirectBookingResponse({
    required this.bookingId,
  });

  factory DirectBookingResponse.fromEntity(DirectBookingResponseEntity entity) {
    return DirectBookingResponse(
      bookingId: entity.bookingId,
    );
  }
}

@JsonSerializable()
class DirectBookingResponseEntity {
  @JsonKey(name: 'booking_id')
  final String bookingId;

  DirectBookingResponseEntity({
    required this.bookingId,
  });
  factory DirectBookingResponseEntity.fromJson(Map<String, dynamic> data) =>
      _$DirectBookingResponseEntityFromJson(data);

  Map<String, dynamic> toJson() => _$DirectBookingResponseEntityToJson(this);
}
