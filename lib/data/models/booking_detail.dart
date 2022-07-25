// import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:themotorwash/data/models/event.dart';
import 'package:themotorwash/data/models/payment.dart';
import 'package:themotorwash/data/models/price_time_list_model.dart';
import 'package:themotorwash/data/models/review.dart';
import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';

part 'booking_detail.g.dart';

class BookingDetailModel {
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bookingId;
  final BookingStatus? status;
  final DateTime? statusChangedTime;
  final String? otp;
  final VehicleModel? vehicleModel;
  final Store? store;
  final int? bookedBy;
  final bool? isRefunded;
  final List<PriceTimeListModel>? services;
  final String? amount;
  final PaymentModel? payment;
  final EventModel? event;
  final Review? review;

  final String? remainingAmount;
  final bool isMultiDay;

  BookingDetailModel(
      {this.id,
      this.createdAt,
      this.updatedAt,
      this.bookingId,
      this.status,
      this.statusChangedTime,
      this.otp,
      this.event,
      this.vehicleModel,
      this.store,
      this.bookedBy,
      this.isRefunded,
      this.services,
      this.amount,
      this.payment,
      this.review,
      this.remainingAmount,
      required this.isMultiDay});

  factory BookingDetailModel.fromEntity(BookingDetailEntity e) {
    return BookingDetailModel(
        amount: e.amount,
        bookedBy: e.bookedBy,
        bookingId: e.bookingId,
        createdAt: e.createdAt != null ? DateTime.parse(e.createdAt!) : null,
        updatedAt: e.updatedAt != null ? DateTime.parse(e.updatedAt!) : null,
        event: e.event != null ? EventModel.fromEntity(e.event!) : null,
        id: e.id,
        isRefunded: e.isRefunded,
        otp: e.otp,
        payment: e.payment != null ? PaymentModel.fromEntity(e.payment!) : null,
        services: e.services != null
            ? e.services!
                .map<PriceTimeListModel>(
                    (e) => PriceTimeListModel.fromEntity(e))
                .toList()
            : null,
        status: e.status != null
            ? getBookingStatusFromCode(e.status!)
            : BookingStatus.notDefined,
        statusChangedTime: e.statusChangedTime != null
            ? DateTime.parse(e.statusChangedTime!)
            : null,
        store: e.store != null ? Store.fromEntity(e.store!) : null,
        vehicleModel: e.vehicleModel != null
            ? VehicleModel.fromEntity(e.vehicleModel!)
            : null,
        review: e.review != null ? Review.fromEntity(e.review!) : null,
        remainingAmount: e.remainingAmount,
        isMultiDay: e.isMultiDay);
  }

  @override
  String toString() {
    return 'BookingDetailModel(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, bookingId: $bookingId, status: $status, statusChangedTime: $statusChangedTime, otp: $otp, vehicleModel: $vehicleModel, store: $store, bookedBy: $bookedBy, isRefunded: $isRefunded, services: $services, amount: $amount, payment: $payment, event: $event, review: $review, remainingAmount: $remainingAmount)';
  }
}

@JsonSerializable(explicitToJson: true)
class BookingDetailEntity {
  final int? id;
  @JsonKey(name: 'booking_id')
  final String? bookingId;
  final PaymentEntity? payment;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'booking_status')
  final String? status;
  final String? amount;
  @JsonKey(name: 'remaining_amount')
  final String? remainingAmount;

  @JsonKey(name: 'status_changed_time')
  final String? statusChangedTime;

  final String? otp;
  final EventEntity? event;

  @JsonKey(name: 'vehicle_model')
  final VehicleModelEntity? vehicleModel;

  final StoreEntity? store;

  @JsonKey(name: 'booked_by')
  final int? bookedBy;

  @JsonKey(name: 'is_refunded')
  final bool? isRefunded;
  @JsonKey(name: 'price_times')
  final List<PriceTimeListEntity>? services;

  final ReviewEntity? review;
  @JsonKey(name: 'is_multi_day')
  final bool isMultiDay;
  BookingDetailEntity(
      {this.id,
      this.bookingId,
      required this.payment,
      this.createdAt,
      this.updatedAt,
      this.status,
      this.amount,
      this.statusChangedTime,
      this.otp,
      this.event,
      this.vehicleModel,
      this.store,
      this.bookedBy,
      this.isRefunded,
      this.services,
      this.review,
      this.remainingAmount,
      required this.isMultiDay});

  factory BookingDetailEntity.fromJson(Map<String, dynamic> data) =>
      _$BookingDetailEntityFromJson(data);

  Map<String, dynamic> toJson() => _$BookingDetailEntityToJson(this);
}

BookingStatus getBookingStatusFromCode(String code) {
  switch (code) {
    case 'INITIATED':
      return BookingStatus.initiated;
    case 'PAYMENT_SUCCESS':
      return BookingStatus.paymentSuccess;
    case 'PAYMENT_FAILED':
      return BookingStatus.paymentFailed;
    case 'NOT_ATTENDED':
      return BookingStatus.notAttended;
    case 'SERVICE_STARTED':
      return BookingStatus.serviceStarted;
    case 'SERVICE_COMPLETED':
      return BookingStatus.serviceCompleted;
    case 'CANCELLATION_REQUEST_APPROVED':
      return BookingStatus.cancellationRequestApproved;
    case 'CANCELLATION_REQUEST_REJECTED':
      return BookingStatus.cancellationRequestRejected;
    case 'CANCELLATION_REQUEST_SUBMITTED':
      return BookingStatus.cancellationRequestSubmitted;
    case 'SUCCESS_WITHOUT_PAYMENT':
      return BookingStatus.successWithoutPayment;

    default:
      return BookingStatus.notDefined;
  }
}

enum BookingStatus {
  initiated,
  successWithoutPayment,
  paymentSuccess,
  paymentFailed,
  notAttended,
  serviceStarted,
  serviceCompleted,
  notDefined,
  cancellationRequestRejected,
  cancellationRequestApproved,
  cancellationRequestSubmitted
}
