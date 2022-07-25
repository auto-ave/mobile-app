import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:themotorwash/data/models/initiate_paytm_payment.dart';
import 'package:themotorwash/data/repos/payment_repository.dart';
import 'package:themotorwash/data/models/paytm_payment_response.dart';

part 'paytm_payment_event.dart';
part 'paytm_payment_state.dart';

class PaytmPaymentBloc extends Bloc<PaytmPaymentEvent, PaytmPaymentState> {
  final PaymentRepository _paymentRepository;
  PaytmPaymentBloc({required PaymentRepository paymentRepository})
      : _paymentRepository = paymentRepository,
        super(PaytmPaymentInitial()) {
    on<PaytmPaymentEvent>((event, emit) async {
      if (event is InitiatePaytmPaymentApi) {
        await _mapInitiatePaytmPaymentApiToState(
            date: event.date,
            bay: event.bay,
            slotStart: event.slotStart,
            slotEnd: event.slotEnd,
            emit: emit);
      } else if (event is CheckPaytmPaymentStatus) {
        await _mapCheckPaytmPaymentStatusToState(
            paymentResponseModel: event.paymentResponseModel, emit: emit);
      } else if (event is StartPaytmTransaction) {
        await _mapStartPaytmTransactionToState(
            initiatedPayment: event.initiatedPayment, emit: emit);
      }
    });
  }

  // @override
  // Stream<PaytmPaymentState> mapEventToState(
  //   PaytmPaymentEvent event,
  // ) async* {
  // if (event is InitiatePaytmPaymentApi) {
  //   yield* _mapInitiatePaytmPaymentApiToState(
  //       date: event.date,
  //       bay: event.bay,
  //       slotStart: event.slotStart,
  //       slotEnd: event.slotEnd);
  // } else if (event is CheckPaytmPaymentStatus) {
  //   yield* _mapCheckPaytmPaymentStatusToState(
  //       paymentResponseModel: event.paymentResponseModel);
  // } else if (event is StartPaytmTransaction) {
  //   yield* _mapStartPaytmTransactionToState(
  //       initiatedPayment: event.initiatedPayment);
  // }
  // }

  FutureOr<void> _mapInitiatePaytmPaymentApiToState(
      {required String date,
      required int? bay,
      required String slotStart,
      required String? slotEnd,
      required Emitter<PaytmPaymentState> emit}) async {
    try {
      emit(InitiatingPaytmPayment());
      InitiatePaytmPaymentModel initiatedPayment =
          await _paymentRepository.initiatePaytmPayment(
              date: date, bay: bay, slotStart: slotStart, slotEnd: slotEnd);
      emit(PaytmPaymentInitiated(initiatedPayment: initiatedPayment));
    } catch (e) {
      emit(FailedToInitiatePaytmPayment(message: e.toString()));
    }
  }

  FutureOr<void> _mapStartPaytmTransactionToState(
      {required InitiatePaytmPaymentModel initiatedPayment,
      required Emitter<PaytmPaymentState> emit}) async {
    try {
      PaytmPaymentResponseModel paymentResponseModel = await _paymentRepository
          .startPaytmTransaction(initiatedPayment: initiatedPayment);
      emit(PaytmPaymentSuccessful(paymentResponseModel: paymentResponseModel));
    } on PlatformException catch (e) {
      print("caught exception");
      emit(PaytmPaymentFailed(message: e.toString(), e: e));
    }
  }

  FutureOr<void> _mapCheckPaytmPaymentStatusToState(
      {required PaytmPaymentResponseModel paymentResponseModel,
      required Emitter<PaytmPaymentState> emit}) async {
    try {
      print(paymentResponseModel.toString());
      PaytmPaymentResponseModel paymentResponse = await _paymentRepository
          .checkPaytmPaymentStatus(paymentResponseModel: paymentResponseModel);

      emit(CheckedPaytmPaymentStatus(paymentResponseModel: paymentResponse));
    } catch (e) {
      emit(FailedToCheckPaytmPaymentStatus(message: e.toString()));
    }
  }
}
