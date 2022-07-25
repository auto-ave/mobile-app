import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:themotorwash/blocs/cancel_booking_data/cancel_booking_data_bloc.dart';
import 'package:themotorwash/blocs/cancel_booking_request/cancel_booking_request_bloc.dart';
import 'package:themotorwash/data/models/cancel_booking_data.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/explore/explore_screen.dart';
import 'package:themotorwash/ui/screens/payment_choice/payment_choice.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/utils/utils.dart';

class CancelOrderScreen extends StatefulWidget {
  final String bookingId;
  static final String route = "/cancelOrderScreen";
  const CancelOrderScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  State<CancelOrderScreen> createState() {
    FlutterUxcam.tagScreenName(route);
    return _CancelOrderScreenState();
  }
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  late final CancelBookingDataBloc _cancelBookingDataBloc;
  late final CancelBookingRequestBloc _cancelBookingRequestBloc;
  @override
  void initState() {
    super.initState();
    _cancelBookingDataBloc = CancelBookingDataBloc(
        repository: RepositoryProvider.of<Repository>(context));
    _cancelBookingRequestBloc = CancelBookingRequestBloc(
        repository: RepositoryProvider.of<Repository>(context));
    _cancelBookingDataBloc
        .add(GetCancelBookingData(bookingId: widget.bookingId));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _cancelBookingDataBloc.close();
    _cancelBookingRequestBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    String selectedReason = "";
    return WillPopScope(
      onWillPop: () async {
        if (_cancelBookingRequestBloc.state is CancelBookingRequestSuccess) {
          Navigator.pushNamedAndRemoveUntil(
              context, ExploreScreen.route, (route) => false);
          return false;
        }
        return true;
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          print('on tappppp');
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
            appBar: getAppBarWithBackButton(context: context),
            bottomNavigationBar: BlocBuilder<CancelBookingRequestBloc,
                    CancelBookingRequestState>(
                bloc: _cancelBookingRequestBloc,
                builder: (context, state) {
                  if (state is CancelBookingRequestSuccess) {
                    return Container(
                      height: 0,
                      width: 0,
                    );
                  }
                  return BlocBuilder<CancelBookingDataBloc,
                          CancelBookingDataState>(
                      bloc: _cancelBookingDataBloc,
                      builder: (context, state) {
                        if (state is CancelBookingDataLoaded) {
                          return BottomSubmitButton(
                            onTap: () {
                              if (selectedReason.trim().isNotEmpty) {
                                _cancelBookingRequestBloc.add(
                                    SubmitCancelBookingRequest(
                                        reason: selectedReason,
                                        bookingId: widget.bookingId));
                              } else {
                                showSnackbar(context, 'Please select a reason');
                              }
                            },
                            title: 'Submit',
                            cancelBookingRequestBloc: _cancelBookingRequestBloc,
                          );
                        }
                        return Container(
                          height: 0,
                          width: 0,
                        );
                      });
                }),
            body: BlocBuilder<CancelBookingRequestBloc,
                    CancelBookingRequestState>(
                bloc: _cancelBookingRequestBloc,
                builder: (context, state) {
                  if (state is CancelBookingRequestSuccess) {
                    return SizedBox(
                      child: CancellationRequestSentWidget(),
                      width: 100.w,
                    );
                  }
                  return BlocBuilder<CancelBookingDataBloc,
                          CancelBookingDataState>(
                      bloc: _cancelBookingDataBloc,
                      builder: (context, state) {
                        if (state is CancelBookingDataLoading) {
                          return Center(
                            child: loadingAnimation(),
                          );
                        }
                        if (state is CancelBookingDataError) {
                          return Center(
                            child: ErrorScreen(
                              ctaType: ErrorCTA.reload,
                              onCTAPressed: () {
                                _cancelBookingDataBloc.add(GetCancelBookingData(
                                    bookingId: widget.bookingId));
                              },
                            ),
                          );
                        }
                        if (state is CancelBookingDataLoaded) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Submit order cancellation request',
                                  style: SizeConfig.kStyle20Bold,
                                ),
                                SizeConfig.kverticalMargin8,
                                CancelDescription(
                                  isRefundable: state.data.isRefundable,
                                  refundAmount: state.data.refundAmount,
                                ),
                                SizeConfig.kverticalMargin24,
                                ReasonsOfCancellationWidget(
                                  reasons: state.data.reasons,
                                  onReasonChanged: (reason) {
                                    selectedReason = reason;
                                  },
                                )
                              ],
                            ),
                          );
                        }
                        return Center(
                          child: ErrorScreen(
                            ctaType: ErrorCTA.reload,
                            onCTAPressed: () {
                              _cancelBookingDataBloc.add(GetCancelBookingData(
                                  bookingId: widget.bookingId));
                            },
                          ),
                        );
                      });
                })),
      ),
    );
  }
}

class BottomSubmitButton extends StatefulWidget {
  final VoidCallback onTap;
  final String title;
  final CancelBookingRequestBloc cancelBookingRequestBloc;
  const BottomSubmitButton(
      {Key? key,
      required this.onTap,
      required this.title,
      required this.cancelBookingRequestBloc})
      : super(key: key);

  @override
  State<BottomSubmitButton> createState() => _BottomSubmitButtonState();
}

class _BottomSubmitButtonState extends State<BottomSubmitButton> {
  @override
  void initState() {
    super.initState();
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            children: <Widget>[
              Spacer(),
              BlocConsumer<CancelBookingRequestBloc, CancelBookingRequestState>(
                  listener: (context, state) {
                    if (state is CancelBookingRequestError) {
                      showSnackbar(context,
                          'Failed to send cancellation request. Please try again later');
                    }
                    if (state is CancelBookingRequestSuccess) {
                      showSnackbar(context,
                          'Successfully sent the request. Please wait for the request to be approved.');
                    }
                  },
                  bloc: widget.cancelBookingRequestBloc,
                  builder: (context, state) {
                    if (state is CancelBookingRequestLoading) {
                      return CommonTextButton(
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: SizeConfig.kPrimaryColor,
                            ),
                          ),
                        ),
                        backgroundColor: SizeConfig.kPrimaryColor,
                        buttonSemantics: 'Loading Cancel Button',
                      );
                    }

                    return CommonTextButton(
                      onPressed: widget.onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8),
                        child: Text(widget.title,
                            style: SizeConfig.kStyle14W500
                                .copyWith(color: Colors.white)),
                      ),
                      backgroundColor: SizeConfig.kPrimaryColor,
                      buttonSemantics: 'Send Cancel Button Request',
                    );
                  })
            ],
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

class CancelDescription extends StatelessWidget {
  final num refundAmount;
  final bool isRefundable;
  const CancelDescription(
      {Key? key, required this.refundAmount, required this.isRefundable})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isRefundable
        ? Text.rich(TextSpan(children: [
            TextSpan(
                text: 'Refund of ',
                style: SizeConfig.kStyle16.copyWith(
                  color: Colors.black,
                )),
            TextSpan(
                text: '₹$refundAmount ',
                style: SizeConfig.kStyle16Bold
                    .copyWith(color: SizeConfig.kPrimaryColor)),
            TextSpan(
                text: 'will be initiated in 1-2 business days.',
                style: SizeConfig.kStyle16.copyWith(
                  color: Colors.black,
                )),
          ]))
        : Text(
            'You will be charged the token amount because the cancellation is after 12 hours of the orignal slot timing');
  }
}

class ReasonsOfCancellationWidget extends StatefulWidget {
  final List<String> reasons;
  final Function(String reason) onReasonChanged;
  const ReasonsOfCancellationWidget(
      {Key? key, required this.reasons, required this.onReasonChanged})
      : super(key: key);

  @override
  State<ReasonsOfCancellationWidget> createState() =>
      _ReasonsOfCancellationWidgetState();
}

class _ReasonsOfCancellationWidgetState
    extends State<ReasonsOfCancellationWidget> {
  String selectedReason = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Reason of cancellation',
          style: SizeConfig.kStyle20Bold,
        ),
        SizeConfig.kverticalMargin16,
        ...widget.reasons
            .map((e) => RadioListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  title: Text(e),
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value as String;
                      widget.onReasonChanged(selectedReason);
                    });
                  },
                  value: e,
                ))
            .toList(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              title: Text('Any other reason'),
              groupValue: selectedReason,
              onChanged: (value) {
                setState(() {
                  selectedReason = value as String;
                  widget.onReasonChanged('');
                });
              },
              value: 'other',
            ),
            selectedReason == 'other'
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 10.h,
                    child: TextField(
                      onChanged: (value) {
                        widget.onReasonChanged(value);
                      },
                      style: TextStyle(fontSize: 18),
                      maxLines: 100,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                BorderSide(color: SizeConfig.kPrimaryColor)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                BorderSide(color: SizeConfig.kPrimaryColor)),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ],
    );
  }
}

class CancellationRequestSentWidget extends StatelessWidget {
  const CancellationRequestSentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        Stack(
          // crossAxisAlignment: CrossAxisAlignment.end,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: 100.w,
              child: Column(
                children: [
                  Text(
                    'Cancellation Request Sent',
                    style: SizeConfig.kStyle16W500,
                  ),
                  Text(
                    'We have recieved your request.',
                    style: SizeConfig.kStyle12
                        .copyWith(color: SizeConfig.kGreyTextColor),
                  ),
                  Text(
                    'We will get back to you soon.',
                    style: SizeConfig.kStyle12
                        .copyWith(color: SizeConfig.kGreyTextColor),
                  ),
                ],
              ),
            ),
            Positioned(
              child: Image.asset('assets/images/victory.png'),
              right: 0,
              bottom: 0,
            ),
          ],
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 100.w,
            child: CommonTextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, ExploreScreen.route, (route) => false);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Home',
                  style: SizeConfig.kStyle14.copyWith(color: Colors.white),
                ),
              ),
              backgroundColor: SizeConfig.kPrimaryColor,
              buttonSemantics: 'Cancel Request Sent Home',
            ),
          ),
        ),
      ],
    );
  }
}
