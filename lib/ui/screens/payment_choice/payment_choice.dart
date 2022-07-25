import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:themotorwash/blocs/payment_choice/payment_choice_bloc.dart';
import 'package:themotorwash/blocs/paytm_payment/paytm_payment_bloc.dart';
import 'package:themotorwash/blocs/razorpay_payment/bloc/razorpay_payment_bloc.dart';
import 'package:themotorwash/data/models/initiate_paytm_payment.dart';
import 'package:themotorwash/data/models/initiate_razorpay_payment.dart';
import 'package:themotorwash/data/models/multi_day_slot.dart';
import 'package:themotorwash/data/models/multi_day_slot_detail.dart';
import 'package:themotorwash/data/models/paytm_payment_response.dart';
import 'package:themotorwash/data/models/razorpay_payment_response.dart';
import 'package:themotorwash/data/models/slot.dart';
import 'package:themotorwash/data/repos/payment_repository.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/ui/widgets/or_divider_widget.dart';
import 'package:themotorwash/utils/utils.dart';

class PaymentChoiceScreen extends StatefulWidget {
  static final String route = '/paymentChoice';
  final Slot? slot;
  final DateTime dateSelected;
  final MultiDaySlot? multiDaySlot;
  const PaymentChoiceScreen(
      {Key? key,
      required this.dateSelected,
      required this.slot,
      required this.multiDaySlot})
      : super(key: key);

  @override
  _PaymentChoiceScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    FlutterUxcam.occludeSensitiveScreen(true);
    return _PaymentChoiceScreenState();
  }
}

class _PaymentChoiceScreenState extends State<PaymentChoiceScreen> {
  int currentSelectedIndex = 1;
  late final PaymentChoiceBloc _paymentChoiceBloc;
  late RazorpayPaymentBloc _razorPaymentBloc;
  late SimpleFontelicoProgressDialog _dialog;
  @override
  void initState() {
    // TODO: implement initState
    FirebaseAnalytics.instance.logScreenView(screenName: 'Payment Choice');
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);
    _razorPaymentBloc = RazorpayPaymentBloc(
        paymentRepository: RepositoryProvider.of<PaymentRepository>(context),
        razorpayInstance: Razorpay());
    _paymentChoiceBloc = PaymentChoiceBloc(
        repository: RepositoryProvider.of<Repository>(context));
    _paymentChoiceBloc.add(GetPaymentChoices());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _paymentChoiceBloc.close();
    _razorPaymentBloc.close();
  }

  void showDialog(String message) async {
    _dialog.show(
        message: message,
        height: 30.h,
        width: 40.h,
        type: SimpleFontelicoProgressDialogType.normal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBarWithBackButton(
            context: context,
            title: Text(
              'Select Payment Choice',
              style: SizeConfig.kStyleAppBarTitle,
            )),
        bottomNavigationBar: BottomButton(
          title: 'Continue',
          onTap: () {
            // Logger().d(widget.multiDaySlot!.startTime);
            _razorPaymentBloc.add(
              InitiateRazorpayPayment(
                slotStart: widget.slot != null
                    ? widget.slot!.startString!
                    : widget.multiDaySlot!.startTime,
                slotEnd: widget.slot != null ? widget.slot!.endString : null,
                bay: widget.slot != null ? widget.slot!.bays![0] : null,
                date: DateFormat('y-M-d').format(
                  widget.dateSelected,
                ),
              ),
            );
          },
        ),
        body: BlocListener<RazorpayPaymentBloc, RazorpayPaymentState>(
          bloc: _razorPaymentBloc,
          listener: (context, state) {
            if (state is InitiatingRazorpayPayment) {
              showDialog('Initiating your transaction...Please wait');
            }
            if (state is InitiatedRazorpayPayment) {
              startRazorpayTransaction(
                  initiatedPayment: state.initiatedPayment);
            }
            if (state is FailedToInitiateRazorpayPayment) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to initiate payment.')));
              _dialog.hide();
            }
            if (state is RazorpayPaymentSuccess) {
              _razorPaymentBloc.add(CheckRazorpayPaymentStatus(
                  paymentResponseModel: state.successResponse,
                  bookingId: state.bookingId,
                  isFailure: false));
            }
            if (state is RazorpayPaymentFailure) {
              print('State is RazorpayPaymentFailure');
              _razorPaymentBloc.add(CheckRazorpayPaymentStatus(
                  paymentResponseModel: RazorpayPaymentResponse(
                      razorpayOrderId: '',
                      razorpayPaymentId: '',
                      razorpaySignature: ''),
                  bookingId: state.bookingId,
                  isFailure: true));
              // Navigator.pushNamedAndRemoveUntil(
              //     context, BookingSummaryScreen.route, (route) => false,
              //     arguments: BookingSummaryScreenArguments(
              //         isTransactionSuccesful: false,
              //         bookingId: state.bookingId));
              // if (state.e!.details == null) {
              //   _dialog.hide();
              //   showSnackbar(context,
              //       "Error processing your payment. Please try again.");
              //   print('errr process');
              // } else {
              //   var logger = Logger();

              //   logger.d("lolz" +
              //       jsonDecode(
              //         jsonEncode(state.e!.details),
              //       ).toString() +
              //       "lolz");
              //   print("lolz" +
              //       jsonDecode(
              //         jsonEncode(state.e!.details),
              //       ).toString() +
              //       "lolz");
              //   _paytmPaymentBloc.add(CheckRazorpayPaymentStatus(
              //     paymentResponseModel: RazorpayPaymentResponseModel.fromEntity(
              //       RazorpayPaymentResponseEntity.fromJson(
              //         jsonDecode(
              //           jsonEncode(state.e!.details),
              //         ),
              //       ),
              //     ),
              //   ));
              //   // print(RazorpayPaymentResponseModel.fromEntity(
              //   //   RazorpayPaymentResponseEntity.fromJson(
              //   //     jsonDecode(
              //   //       jsonEncode(state.e!.details),
              //   //     ),
              //   //   ),
              //   // ).toEntity().toJson());
              // }
            }
            if (state is CheckingRazorpayPaymentStatus) {
              _dialog.hide();
              showDialog('Checking payment status..Please wait!');
            }
            if (state is FailedToCheckRazorpayPaymentStatus) {
              _dialog.hide();
              // showSnackbar(context, 'Transaction Failed. ');
              Navigator.pushNamedAndRemoveUntil(
                  context, BookingSummaryScreen.route, (route) => false,
                  arguments: BookingSummaryScreenArguments(
                      isTransactionSuccesful: false,
                      bookingId: state.bookingId));
            }
            if (state is CheckedRazorpayPaymentStatus) {
              _dialog.hide();
              print(state.paymentResponseModel.toString() + "ezepz");
              Navigator.pushNamedAndRemoveUntil(
                  context, BookingSummaryScreen.route, (route) => false,
                  arguments: BookingSummaryScreenArguments(
                      isTransactionSuccesful: true,
                      bookingId: state.bookingId));
            }
          },
          child: BlocBuilder<PaymentChoiceBloc, PaymentChoiceState>(
            bloc: _paymentChoiceBloc,
            builder: (context, state) {
              if (state is PaymentChoiceLoading) {
                return Center(
                  child: loadingAnimation(),
                );
              }
              if (state is PaymentChoiceError) {
                return Center(
                  child: ErrorScreen(
                    ctaType: ErrorCTA.reload,
                    onCTAPressed: () {
                      _paymentChoiceBloc.add(GetPaymentChoices());
                    },
                  ),
                );
              }

              if (state is PaymentChoiceLoaded) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      PaymentChoiceTile(
                        amount:
                            state.paymentChoices[0].amount.toString().rupees(),
                        descriptionWidget:
                            Text(state.paymentChoices[0].description),
                        isSelected: currentSelectedIndex == 0,
                        paymentChoice: state.paymentChoices[0].title,
                        primaryColor: Colors.grey,
                        isActive: state.paymentChoices[0].active,
                        onTap: (index) {
                          if (state.paymentChoices[0].active) {
                            setState(() {
                              currentSelectedIndex = index;
                            });
                          } else {
                            showSnackbar(context,
                                'Option not available for the select store');
                          }
                        },
                        widgetIndex: 0,
                        buttonSemantics: state.paymentChoices[0].title,
                      ),
                      SizeConfig.kverticalMargin16,
                      ORWithDividerWidget(),
                      SizeConfig.kverticalMargin16,
                      PaymentChoiceTile(
                        amount:
                            state.paymentChoices[1].amount.toString().rupees(),
                        descriptionWidget:
                            Text(state.paymentChoices[1].description),
                        isActive: state.paymentChoices[1].active,
                        isSelected: currentSelectedIndex == 1,
                        paymentChoice: state.paymentChoices[1].title,
                        primaryColor: SizeConfig.kPrimaryColor,
                        onTap: (index) {
                          if (state.paymentChoices[1].active) {
                            setState(() {
                              currentSelectedIndex = index;
                            });
                          } else {
                            showSnackbar(context,
                                'Option not available for the select store');
                          }
                        },
                        widgetIndex: 1,
                        buttonSemantics: state.paymentChoices[1].title,
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 4),
                        child: TermsCancellation(terms: [
                          'In case of cancelling of order before 12 hours of the slot whole refund will be provided.',
                          'In case of cancelling of order after 12 hours of the slot token amount will be charged.'
                        ]),
                      )
                    ],
                  ),
                );
              }
              return ErrorScreen(
                ctaType: ErrorCTA.reload,
                onCTAPressed: () {
                  _paymentChoiceBloc.add(GetPaymentChoices());
                },
              );
            },
          ),
        ));
  }

  void startRazorpayTransaction(
      {required InitiateRazorpayPaymentModel initiatedPayment}) {
    _razorPaymentBloc
        .add(StartRazorpayTransaction(initiatedPayment: initiatedPayment));
  }
}

class BottomButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  const BottomButton({Key? key, required this.onTap, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              blurRadius: 4,
              color: Color.fromRGBO(0, 0, 0, .08),
              offset: Offset(0, -2))
        ]),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              children: <Widget>[
                Spacer(),
                CommonTextButton(
                  onPressed: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8),
                    child: Text(title,
                        style: SizeConfig.kStyle14W500
                            .copyWith(color: Colors.white)),
                  ),
                  backgroundColor: SizeConfig.kPrimaryColor,
                  buttonSemantics: 'Payment Choice Continue',
                )
              ],
            ),
          ),
        ));
  }
}

class TermsCancellation extends StatelessWidget {
  final List<String> terms;
  const TermsCancellation({Key? key, required this.terms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: terms
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("\u2022 "),
                        Expanded(
                          child: Text(
                            e,
                            style: SizeConfig.kStyle12
                                .copyWith(color: SizeConfig.kGreyTextColor),
                          ),
                        ),
                      ]),
                ))
            .toList());
  }
}

class PaymentChoiceTile extends StatelessWidget {
  final String paymentChoice;
  final String amount;
  final Widget descriptionWidget;
  final bool isSelected;
  final Color primaryColor;
  final int widgetIndex;
  final Function(int index) onTap;
  final bool isActive;
  final String buttonSemantics;

  const PaymentChoiceTile(
      {Key? key,
      required this.amount,
      required this.descriptionWidget,
      required this.isSelected,
      required this.paymentChoice,
      required this.primaryColor,
      required this.onTap,
      required this.widgetIndex,
      required this.buttonSemantics,
      required this.isActive})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          // color: isActive ? Colors.white : Colors.grey.withOpacity(.2),
          color: Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      offset: Offset(0, 8),
                      blurRadius: 24,
                      color: Color.fromRGBO(0, 0, 0, .16))
                ]
              : [],
          borderRadius: BorderRadius.circular(5)),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                paymentChoice,
                style: SizeConfig.kStyle16Bold,
              ),
              Spacer(),
              Text(amount,
                  style: SizeConfig.kStyle16Bold.copyWith(color: primaryColor))
            ],
          ),
          SizeConfig.kverticalMargin8,
          descriptionWidget,
          SizeConfig.kverticalMargin16,
          GestureDetector(
            onTap: () {
              onTap(widgetIndex);
              // mixpanel?.track(buttonSemantics,
              // properties: {'is_active': isActive.toString()});
            },
            child: Container(
              width: 100.w,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  isSelected ? 'Selected' : 'Select',
                  style: SizeConfig.kStyle16Bold.copyWith(
                      color: isSelected ? Colors.white : primaryColor),
                ),
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? (isSelected ? primaryColor : Colors.white)
                    : Colors.grey[300],
                border: isActive
                    ? Border.all(
                        color: primaryColor,
                      )
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
        ],
      ),
    );
  }
}
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:logger/logger.dart';
// import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
// import 'package:themotorwash/blocs/payment_choice/payment_choice_bloc.dart';
// import 'package:themotorwash/blocs/paytm_payment/paytm_payment_bloc.dart';
// import 'package:themotorwash/data/models/initiate_paytm_payment.dart';
// import 'package:themotorwash/data/models/multi_day_slot.dart';
// import 'package:themotorwash/data/models/multi_day_slot_detail.dart';
// import 'package:themotorwash/data/models/paytm_payment_response.dart';
// import 'package:themotorwash/data/models/slot.dart';
// import 'package:themotorwash/data/repos/payment_repository.dart';
// import 'package:themotorwash/data/repos/repository.dart';
// import 'package:themotorwash/navigation/arguments.dart';
// import 'package:themotorwash/theme_constants.dart';
// import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
// import 'package:themotorwash/ui/widgets/common_button.dart';
// import 'package:themotorwash/ui/widgets/error_widget.dart';
// import 'package:themotorwash/ui/widgets/or_divider_widget.dart';
// import 'package:themotorwash/utils/utils.dart';

// class PaymentChoiceScreen extends StatefulWidget {
//   static final String route = '/paymentChoice';
//   final Slot? slot;
//   final DateTime dateSelected;
//   final MultiDaySlot? multiDaySlot;
//   const PaymentChoiceScreen(
//       {Key? key,
//       required this.dateSelected,
//       required this.slot,
//       required this.multiDaySlot})
//       : super(key: key);

//   @override
//   _PaymentChoiceScreenState createState() => _PaymentChoiceScreenState();
// }

// class _PaymentChoiceScreenState extends State<PaymentChoiceScreen> {
//   int currentSelectedIndex = 1;
//   late final PaymentChoiceBloc _paymentChoiceBloc;
//   late PaytmPaymentBloc _paytmPaymentBloc;
//   late SimpleFontelicoProgressDialog _dialog;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _dialog = SimpleFontelicoProgressDialog(
//         context: context, barrierDimisable: false);
//     _paytmPaymentBloc = PaytmPaymentBloc(
//         paymentRepository: RepositoryProvider.of<PaymentRepository>(context));
//     _paymentChoiceBloc = PaymentChoiceBloc(
//         repository: RepositoryProvider.of<Repository>(context));
//     _paymentChoiceBloc.add(GetPaymentChoices());
//   }

//   void showDialog(String message) async {
//     _dialog.show(
//         message: message,
//         height: 30.h,
//         width: 40.h,
//         type: SimpleFontelicoProgressDialogType.normal);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: getAppBarWithBackButton(
//             context: context,
//             title: Text(
//               'Select Payment Choice',
//               style: SizeConfig.kStyleAppBarTitle,
//             )),
//         bottomNavigationBar: BottomButton(
//           title: 'Continue',
//           onTap: () {
//             _paytmPaymentBloc.add(
//               InitiatePaytmPaymentApi(
//                 slotStart: widget.slot != null
//                     ? widget.slot!.startString!
//                     : widget.multiDaySlot!.startTime,
//                 slotEnd: widget.slot != null ? widget.slot!.endString : null,
//                 bay: widget.slot != null ? widget.slot!.bays![0] : null,
//                 date: DateFormat('y-M-d').format(
//                   widget.dateSelected,
//                 ),
//               ),
//             );
//           },
//         ),
//         body: BlocListener<PaytmPaymentBloc, PaytmPaymentState>(
//           bloc: _paytmPaymentBloc,
//           listener: (context, state) {
//             if (state is InitiatingPaytmPayment) {
//               showDialog('Initiating your transaction...Please wait');
//             }
//             if (state is PaytmPaymentInitiated) {
//               startPaytmTransaction(initiatedPayment: state.initiatedPayment);
//             }
//             if (state is FailedToInitiatePaytmPayment) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Failed to initiate payment.')));
//               _dialog.hide();
//             }
//             if (state is PaytmPaymentSuccessful) {
//               _paytmPaymentBloc.add(CheckPaytmPaymentStatus(
//                   paymentResponseModel: state.paymentResponseModel));
//             }
//             if (state is PaytmPaymentFailed) {
//               if (state.e!.details == null) {
//                 _dialog.hide();
//                 showSnackbar(context,
//                     "Error processing your payment. Please try again.");
//                 print('errr process');
//               } else {
//                 var logger = Logger();

//                 logger.d("lolz" +
//                     jsonDecode(
//                       jsonEncode(state.e!.details),
//                     ).toString() +
//                     "lolz");
//                 print("lolz" +
//                     jsonDecode(
//                       jsonEncode(state.e!.details),
//                     ).toString() +
//                     "lolz");
//                 _paytmPaymentBloc.add(CheckPaytmPaymentStatus(
//                   paymentResponseModel: PaytmPaymentResponseModel.fromEntity(
//                     PaytmPaymentResponseEntity.fromJson(
//                       jsonDecode(
//                         jsonEncode(state.e!.details),
//                       ),
//                     ),
//                   ),
//                 ));
//                 // print(PaytmPaymentResponseModel.fromEntity(
//                 //   PaytmPaymentResponseEntity.fromJson(
//                 //     jsonDecode(
//                 //       jsonEncode(state.e!.details),
//                 //     ),
//                 //   ),
//                 // ).toEntity().toJson());
//               }
//             }
//             if (state is CheckingPaytmPaymentStatus) {
//               _dialog.hide();
//               showDialog('Checking payment status..Please wait!');
//             }
//             if (state is FailedToCheckPaytmPaymentStatus) {
//               _dialog.hide();
//               showSnackbar(context, 'Transaction Failed. ' + state.message);
//             }
//             if (state is CheckedPaytmPaymentStatus) {
//               _dialog.hide();
//               print(state.paymentResponseModel.toString() + "ezepz");
//               Navigator.pushNamedAndRemoveUntil(
//                   context, BookingSummaryScreen.route, (route) => false,
//                   arguments: BookingSummaryScreenArguments(
//                       isTransactionSuccesful:
//                           state.paymentResponseModel.status == "TXN_SUCCESS",
//                       bookingId: state.paymentResponseModel.orderId!));
//             }
//           },
//           child: BlocBuilder<PaymentChoiceBloc, PaymentChoiceState>(
//             bloc: _paymentChoiceBloc,
//             builder: (context, state) {
//               if (state is PaymentChoiceLoading) {
//                 return Center(
//                   child: loadingAnimation(),
//                 );
//               }
//               if (state is PaymentChoiceError) {
//                 return Center(
//                   child: ErrorScreen(
//                     ctaType: ErrorCTA.reload,
//                     onCTAPressed: () {
//                       _paymentChoiceBloc.add(GetPaymentChoices());
//                     },
//                   ),
//                 );
//               }

//               if (state is PaymentChoiceLoaded) {
//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//                   child: Column(
//                     children: [
//                       PaymentChoiceTile(
//                           amount: state.paymentChoices[0].amount.toString(),
//                           descriptionWidget:
//                               Text(state.paymentChoices[0].description),
//                           isSelected: currentSelectedIndex == 0,
//                           paymentChoice: state.paymentChoices[0].title,
//                           primaryColor: Colors.grey,
//                           isActive: state.paymentChoices[0].active,
//                           onTap: (index) {
//                             if (state.paymentChoices[0].active) {
//                               setState(() {
//                                 currentSelectedIndex = index;
//                               });
//                             } else {
//                               showSnackbar(context,
//                                   'Option not available for the select store');
//                             }
//                           },
//                           widgetIndex: 0),
//                       SizeConfig.kverticalMargin16,
//                       ORWithDividerWidget(),
//                       SizeConfig.kverticalMargin16,
//                       PaymentChoiceTile(
//                           amount: state.paymentChoices[1].amount.toString(),
//                           descriptionWidget:
//                               Text(state.paymentChoices[1].description),
//                           isActive: state.paymentChoices[1].active,
//                           isSelected: currentSelectedIndex == 1,
//                           paymentChoice: state.paymentChoices[1].title,
//                           primaryColor: SizeConfig.kPrimaryColor,
//                           onTap: (index) {
//                             if (state.paymentChoices[1].active) {
//                               setState(() {
//                                 currentSelectedIndex = index;
//                               });
//                             } else {
//                               showSnackbar(context,
//                                   'Option not available for the select store');
//                             }
//                           },
//                           widgetIndex: 1),
//                       Spacer(),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 24, horizontal: 4),
//                         child: TermsCancellation(terms: [
//                           'In case of cancelling of order before 12 hours of the slot whole refund will be provided.',
//                           'In case of cancelling of order after 12 hours of the slot token amount will be charged.'
//                         ]),
//                       )
//                     ],
//                   ),
//                 );
//               }
//               return ErrorScreen(
//                 ctaType: ErrorCTA.reload,
//                 onCTAPressed: () {
//                   _paymentChoiceBloc.add(GetPaymentChoices());
//                 },
//               );
//             },
//           ),
//         ));
//   }

//   void startPaytmTransaction(
//       {required InitiatePaytmPaymentModel initiatedPayment}) {
//     _paytmPaymentBloc
//         .add(StartPaytmTransaction(initiatedPayment: initiatedPayment));
//   }
// }

// class BottomButton extends StatelessWidget {
//   final VoidCallback onTap;
//   final String title;
//   const BottomButton({Key? key, required this.onTap, required this.title})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         decoration: BoxDecoration(color: Colors.white, boxShadow: [
//           BoxShadow(
//               blurRadius: 4,
//               color: Color.fromRGBO(0, 0, 0, .08),
//               offset: Offset(0, -2))
//         ]),
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
//             child: Row(
//               children: <Widget>[
//                 Spacer(),
//                 CommonTextButton(
//                     onPressed: onTap,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 8.0, horizontal: 8),
//                       child: Text(title,
//                           style: SizeConfig.kStyle14W500
//                               .copyWith(color: Colors.white)),
//                     ),
//                     backgroundColor: SizeConfig.kPrimaryColor)
//               ],
//             ),
//           ),
//         ));
//   }
// }

// class TermsCancellation extends StatelessWidget {
//   final List<String> terms;
//   const TermsCancellation({Key? key, required this.terms}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: terms
//             .map((e) => Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text("\u2022 "),
//                         Expanded(
//                           child: Text(
//                             e,
//                             style: SizeConfig.kStyle12
//                                 .copyWith(color: SizeConfig.kGreyTextColor),
//                           ),
//                         ),
//                       ]),
//                 ))
//             .toList());
//   }
// }

// class PaymentChoiceTile extends StatelessWidget {
//   final String paymentChoice;
//   final String amount;
//   final Widget descriptionWidget;
//   final bool isSelected;
//   final Color primaryColor;
//   final int widgetIndex;
//   final Function(int index) onTap;
//   final bool isActive;

//   const PaymentChoiceTile(
//       {Key? key,
//       required this.amount,
//       required this.descriptionWidget,
//       required this.isSelected,
//       required this.paymentChoice,
//       required this.primaryColor,
//       required this.onTap,
//       required this.widgetIndex,
//       required this.isActive})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           // color: isActive ? Colors.white : Colors.grey.withOpacity(.2),
//           color: Colors.white,
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                       offset: Offset(0, 8),
//                       blurRadius: 24,
//                       color: Color.fromRGBO(0, 0, 0, .16))
//                 ]
//               : [],
//           borderRadius: BorderRadius.circular(5)),
//       padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 paymentChoice,
//                 style: SizeConfig.kStyle16Bold,
//               ),
//               Spacer(),
//               Text(amount,
//                   style: SizeConfig.kStyle16Bold.copyWith(color: primaryColor))
//             ],
//           ),
//           SizeConfig.kverticalMargin8,
//           descriptionWidget,
//           SizeConfig.kverticalMargin16,
//           GestureDetector(
//             onTap: () => onTap(widgetIndex),
//             child: Container(
//               width: 100.w,
//               padding: EdgeInsets.symmetric(vertical: 8),
//               child: Center(
//                 child: Text(
//                   isSelected ? 'Selected' : 'Select',
//                   style: SizeConfig.kStyle16Bold.copyWith(
//                       color: isSelected ? Colors.white : primaryColor),
//                 ),
//               ),
//               decoration: BoxDecoration(
//                 color: isActive
//                     ? (isSelected ? primaryColor : Colors.white)
//                     : Colors.grey[300],
//                 border: isActive
//                     ? Border.all(
//                         color: primaryColor,
//                       )
//                     : null,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
