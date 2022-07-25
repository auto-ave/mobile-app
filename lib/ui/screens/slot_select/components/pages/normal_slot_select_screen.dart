import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:intl/intl.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:themotorwash/blocs/direct_booking/bloc/direct_booking_bloc.dart';
import 'package:themotorwash/blocs/order_review/order_review_bloc.dart';
import 'package:themotorwash/blocs/paytm_payment/paytm_payment_bloc.dart';
import 'package:themotorwash/blocs/slot_selection/bloc/slot_selection_bloc.dart';
import 'package:themotorwash/data/models/initiate_paytm_payment.dart';
import 'package:themotorwash/data/models/slot.dart';
import 'package:themotorwash/data/repos/payment_repository.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
import 'package:themotorwash/ui/screens/order_review/order_review.dart';
import 'package:themotorwash/ui/screens/slot_select/components/date_selection_tab.dart';
import 'package:themotorwash/ui/screens/slot_select/components/pages/multi_day_slot_select_screen.dart';
import 'package:themotorwash/ui/screens/slot_select/components/slot_selection_tab.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/utils/utils.dart';

class NormalSlotSelectScreen extends StatefulWidget {
  NormalSlotSelectScreen(
      {Key? key,
      required this.cartTotal,
      required this.cartId,
      required this.isOldPaymentRoute})
      : super(key: key);
  final String cartTotal;
  final String cartId;
  final bool isOldPaymentRoute;

  static final String route = '/normalSlotSelect';
  @override
  _NormalSlotSelectScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    return _NormalSlotSelectScreenState();
  }
}

class _NormalSlotSelectScreenState extends State<NormalSlotSelectScreen> {
  int currentSelectedSlotIndex = -1;
  int currentSelectedDateIndex = 0;
  late DateTime sevenDaysFromNow;
  List<DateTime> calendarDays = [];

  late SlotSelectionBloc _bloc;
  late DirectBookingBloc _directBookingBloc;
  late SimpleFontelicoProgressDialog _dialog;

  late OrderReviewBloc _orderReviewBloc;
  final _cancelToken = CancelToken();
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
    _bloc.add(GetSlots(
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

  @override
  Widget build(BuildContext context) {
    // return MultiDaySlotSelectScreen(
    //     cartTotal: widget.cartTotal, cartId: widget.cartId);
    return Scaffold(
      appBar: getAppBarWithBackButton(
          context: context,
          title: Text(
            'Select Slot',
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
                    currentSelectedSlotIndex = -1;
                  });
                  _bloc.add(GetSlots(
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
            Expanded(
                child: BlocBuilder<SlotSelectionBloc, SlotSelectionState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is SlotSelectionInitial) {
                  return Center(child: Text('Select a Date'));
                }
                if (state is LoadingSlots) {
                  return Center(
                    child: loadingAnimation(),
                  );
                }
                if (state is SlotsLoaded) {
                  var slots = state.slots;
                  return
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //   child:
                      SlotSelectionTab(
                    slots: slots
                        .map<SlotSelectionTabItem>(
                          (e) => SlotSelectionTabItem(
                            startTime:
                                e.start!.format(context).replaceAll(' ', ''),
                            endTime: e.end!.format(context).replaceAll(' ', ''),
                            slotsAvailable: e.count!,
                          ),
                        )
                        .toList(),
                    currentSelectedTabIndex: currentSelectedSlotIndex,
                    onTap: (int tabIndex) {
                      setState(() {
                        currentSelectedSlotIndex = tabIndex;
                      });
                    },
                    // ),
                  );
                }
                if (state is SlotSelectionError) {
                  return Center(
                    child: ErrorScreen(
                      ctaType: ErrorCTA.reload,
                      onCTAPressed: () {
                        _bloc.add(GetSlots(
                            date: DateFormat('y-M-d')
                                .format(calendarDays[currentSelectedDateIndex]),
                            cartId: widget.cartId,
                            cancelToken: _cancelToken));
                      },
                    ),
                  );
                }
                return Center(
                  child: loadingAnimation(),
                );
              },
            )),
          ],
        ),
      ),
    );
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
                    if (currentSelectedSlotIndex >= 0 &&
                        state is SlotsLoaded &&
                        currentSelectedDateIndex >= 0) {
                      onProceedPressed(state);
                    }
                  },
                  child: Text('Proceed', style: TextStyle(color: Colors.white)),
                  backgroundColor: currentSelectedSlotIndex >= 0
                      ? Colors.green
                      : Colors.grey,
                  buttonSemantics: 'Normal Slots Proceed',
                )
              ],
            ),
          ),
        ));
  }

  void onProceedPressed(SlotsLoaded state) {
    Slot slot = state.slots[currentSelectedSlotIndex];
    DateTime dateSelected = calendarDays[currentSelectedDateIndex];
    if (widget.isOldPaymentRoute) {
      _orderReviewBloc.add(SetSlot(slot: slot));
      Navigator.pushNamed(context, OrderReviewScreen.route,
          arguments: OrderReviewScreenArguments(
              dateSelected: calendarDays[currentSelectedDateIndex],
              isMultiDay: false));
    } else {
      _directBookingBloc.add(DirectBookSlot(
          slotStart: slot.startString!,
          slotEnd: slot.endString!,
          bay: slot.bays![0],
          date: DateFormat('y-M-d').format(
            dateSelected,
          )));
    }
  }
}
