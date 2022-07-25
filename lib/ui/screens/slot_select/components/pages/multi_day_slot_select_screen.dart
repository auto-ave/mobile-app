import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:themotorwash/blocs/direct_booking/bloc/direct_booking_bloc.dart';
import 'package:themotorwash/blocs/order_review/order_review_bloc.dart';
import 'package:themotorwash/blocs/paytm_payment/paytm_payment_bloc.dart';
import 'package:themotorwash/blocs/slot_selection/bloc/slot_selection_bloc.dart';
import 'package:themotorwash/data/models/initiate_paytm_payment.dart';
import 'package:themotorwash/data/models/multi_day_slot_detail.dart';
import 'package:themotorwash/data/models/slot.dart';
import 'package:themotorwash/data/repos/payment_repository.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
import 'package:themotorwash/ui/screens/order_review/order_review.dart';
import 'package:themotorwash/ui/screens/slot_select/components/date_selection_tab.dart';
import 'package:themotorwash/ui/screens/slot_select/components/day_time_selection_bar.dart';
import 'package:themotorwash/ui/screens/slot_select/components/no_slots_widget.dart';
import 'package:themotorwash/ui/screens/slot_select/components/slot_selection_tab.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/utils/utils.dart';
import 'package:collection/collection.dart';

class MultiDaySlotSelectScreen extends StatefulWidget {
  MultiDaySlotSelectScreen(
      {Key? key,
      required this.cartTotal,
      required this.cartId,
      required this.isOldPaymentRoute})
      : super(key: key);
  final String cartTotal;
  final String cartId;
  final bool isOldPaymentRoute;
  static final String route = '/multiDaySlotSelect';
  @override
  _MultiDaySlotSelectScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    return _MultiDaySlotSelectScreenState();
  }
}

class _MultiDaySlotSelectScreenState extends State<MultiDaySlotSelectScreen> {
  int currentSelectedDateIndex = 0;
  late DateTime sevenDaysFromNow;
  List<DateTime> calendarDays = [];

  late SlotSelectionBloc _bloc;
  late DirectBookingBloc _directBookingBloc;
  late OrderReviewBloc _orderReviewBloc;
  final _cancelToken = CancelToken();
  late SimpleFontelicoProgressDialog _dialog;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dialog = SimpleFontelicoProgressDialog(
        context: context, barrierDimisable: false);
    for (int i = 0; i <= 6; i++) {
      calendarDays.add(DateTime.now().add(Duration(days: i)));
    }
    Repository repository = RepositoryProvider.of<Repository>(context);
    _bloc = SlotSelectionBloc(repository: repository);
    _directBookingBloc = DirectBookingBloc(repository: repository);

    _orderReviewBloc = BlocProvider.of<OrderReviewBloc>(context, listen: false);
    _bloc.add(GetMultiDaySlotDetail(
        date:
            DateFormat('y-M-d').format(calendarDays[currentSelectedDateIndex]),
        cartId: widget.cartId,
        cancelToken: _cancelToken));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _directBookingBloc.close();
    _bloc.close();
  }

  void showDialog(String message) async {
    _dialog.show(
        message: message,
        height: 30.h,
        width: 40.h,
        type: SimpleFontelicoProgressDialogType.normal);
  }

  int selectedTimeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBarWithBackButton(
            context: context,
            title: Text(
              'Select Vehicle Drop Time',
              style: SizeConfig.kStyleAppBarTitle,
            )),
        backgroundColor: Colors.white,
        bottomNavigationBar: buildBottom(),
        body: BlocListener<DirectBookingBloc, DirectBookingState>(
            listener: (context, state) {
              if (state is DirectBookingSuccessful) {
                Navigator.pushNamedAndRemoveUntil(
                    context, BookingSummaryScreen.route, (route) => false,
                    arguments: BookingSummaryScreenArguments(
                        isTransactionSuccesful: true,
                        bookingId: state.directBookingResponse.bookingId));
              }
              if (state is DirectBookingLoading) {
                showDialog('Initiating your transaction...Please wait');
              }
              if (state is DirectBookingError) {
                _dialog.hide();
                showSnackbar(context, 'Something went wrong.');
              }
            },
            bloc: _directBookingBloc,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizeConfig.kverticalMargin8,
                DateSelectionTab(
                    dates: calendarDays
                        .map((e) => DateSelectionItem(date: e))
                        .toList(),
                    currentSelectedTabIndex: currentSelectedDateIndex,
                    onTap: (index) {
                      setState(() {
                        currentSelectedDateIndex = index;
                      });
                      _bloc.add(GetMultiDaySlotDetail(
                          date: DateFormat('y-M-d').format(calendarDays[index]),
                          cartId: widget.cartId,
                          cancelToken: _cancelToken));
                    }),
                currentSelectedDateIndex >= 0
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16),
                        child: Text(
                            'Slots on  ${calendarDays[currentSelectedDateIndex].day.ordinalSuffix()}',
                            style: SizeConfig.kStyle20Bold),
                      )
                    : Container(),
                SizeConfig.kverticalMargin16,
                BlocBuilder<SlotSelectionBloc, SlotSelectionState>(
                  bloc: _bloc,
                  builder: (context, state) {
                    if (state is SlotSelectionInitial) {
                      return Expanded(
                          child: Center(child: Text('Select a Date')));
                    }
                    if (state is LoadingSlots) {
                      return Expanded(
                        child: Center(
                          child: loadingAnimation(),
                        ),
                      );
                    }
                    if (state is MultiDaySlotDetailLoaded) {
                      var multiDaySlotDetail = state.multiDaySlotDetail;
                      autoaveLog(multiDaySlotDetail.slots.toString());
                      return Expanded(
                        child: multiDaySlotDetail.slots.isEmpty
                            ? Center(child: NoSlotsWidget())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DayTimeSelectionBar(
                                    tabs: multiDaySlotDetail.slots
                                        .mapIndexed((key, value) {
                                      return DayTimeTabItem(
                                          time: value.time,
                                          image: value.image,
                                          title: value.title,
                                          tabIndex: key,
                                          isSelected: key == selectedTimeIndex);
                                    }).toList(),
                                    selectedIndex: selectedTimeIndex,
                                    onChange: (index) {
                                      autoaveLog('ON CHANGE CALLED' +
                                          index.toString());
                                      selectedTimeIndex = index;
                                    },
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text.rich(TextSpan(children: [
                                          TextSpan(
                                              text:
                                                  'Estimated Completion Date : ',
                                              style: SizeConfig.kStyle14
                                                  .copyWith(
                                                      color: SizeConfig
                                                          .kGreyTextColor)),
                                          TextSpan(
                                              text: multiDaySlotDetail
                                                  .slots[selectedTimeIndex]
                                                  .estimatedCompleteTime,
                                              style: SizeConfig.kStyle16W500)
                                        ])),
                                        multiDaySlotDetail.delayMessage != null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  multiDaySlotDetail
                                                      .delayMessage!,
                                                  style: SizeConfig.kStyle12
                                                      .copyWith(
                                                          color: SizeConfig
                                                              .kReddish),
                                                ),
                                              )
                                            : SizedBox.shrink(),
                                        SizeConfig.kverticalMargin24,
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      );

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //   child:

                    }
                    if (state is SlotSelectionError) {
                      return Expanded(
                        child: Center(
                          child: ErrorScreen(
                            ctaType: ErrorCTA.reload,
                            onCTAPressed: () {
                              _bloc.add(GetMultiDaySlotDetail(
                                  date: DateFormat('y-M-d').format(
                                      calendarDays[currentSelectedDateIndex]),
                                  cartId: widget.cartId,
                                  cancelToken: _cancelToken));
                            },
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: loadingAnimation(),
                    );
                  },
                ),
              ],
            )));
    // );
  }

  Widget buildBottom() {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('₹${widget.cartTotal}',
                        style: TextStyle(
                            fontSize: SizeConfig.kfontSize16,
                            fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'T O T A L',
                      style: TextStyle(
                          fontSize: SizeConfig.kfontSize12,
                          color: Colors.grey[700]),
                    ),
                  ],
                ),
                Spacer(),
                CommonTextButton(
                  onPressed: () {
                    SlotSelectionState state = _bloc.state;
                    if (selectedTimeIndex >= 0 &&
                        state is MultiDaySlotDetailLoaded &&
                        currentSelectedDateIndex >= 0) {
                      onProceedPressed(state);
                    }
                  },
                  child: Text('Proceed', style: TextStyle(color: Colors.white)),
                  backgroundColor:
                      selectedTimeIndex >= 0 ? Colors.green : Colors.grey,
                  buttonSemantics: 'MultiDay Slots Proceed',
                )
              ],
            ),
          ),
        ));
  }

  void onProceedPressed(MultiDaySlotDetailLoaded state) {
    MultiDaySlotDetailModel multiDaySlotDetailModel = state.multiDaySlotDetail;
    DateTime dateSelected = calendarDays[currentSelectedDateIndex];
    if (widget.isOldPaymentRoute) {
      autoaveLog(multiDaySlotDetailModel.slots[selectedTimeIndex].toString());
      _orderReviewBloc.add(SetSlot(
        slot: null,
        multiDaySlot: multiDaySlotDetailModel.slots[selectedTimeIndex],
      ));
      Navigator.pushNamed(context, OrderReviewScreen.route,
          arguments: OrderReviewScreenArguments(
            dateSelected: dateSelected,
            isMultiDay: true,
          ));
    } else {
      _directBookingBloc.add(DirectBookSlot(
          slotStart: multiDaySlotDetailModel.slots[selectedTimeIndex].startTime,
          date: DateFormat('y-M-d').format(
            dateSelected,
          )));
    }
  }
  // String _getStartSlotTimeString() {
  //   switch (selectedTimeIndex) {
  //     case 0:
  //       return '12:00';
  //     case 1:
  //       return '15:00 AM';
  //     case 2:
  //       return '18:00 AM';

  //     default:
  //       return '12:00 AM';
  //   }
  // }
}
