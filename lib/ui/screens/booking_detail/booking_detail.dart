// import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';

import 'package:themotorwash/blocs/booking_summary/bloc/booking_summary_bloc.dart';
import 'package:themotorwash/data/models/booking_detail.dart';
import 'package:themotorwash/data/models/review.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_detail/components/store_detail_tile.dart';
import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
import 'package:themotorwash/ui/screens/cancel_order/cancel_order.dart';
import 'package:themotorwash/ui/screens/explore/explore_screen.dart';
import 'package:themotorwash/ui/screens/feedback/feedback_screen.dart';
import 'package:themotorwash/ui/screens/your_bookings/components/your_bookings_tile.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/dashed_booking_box.dart';
import 'package:themotorwash/ui/widgets/directions_button.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/shimmer_placeholder.dart';
import 'package:themotorwash/utils/utils.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingStatus status;
  final String bookingId;
  const BookingDetailScreen({
    Key? key,
    required this.status,
    required this.bookingId,
  }) : super(key: key);
  static final String route = '/bookingDetailScreen';
  @override
  _BookingDetailScreenState createState() {
    FlutterUxcam.tagScreenName(route);

    return _BookingDetailScreenState();
  }
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late BookingSummaryBloc _bookingSummaryBloc;

  @override
  void initState() {
    super.initState();
    _bookingSummaryBloc = BookingSummaryBloc(
        repository: RepositoryProvider.of<Repository>(context));
    _bookingSummaryBloc.add(GetBookingSummary(bookingId: widget.bookingId));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bookingSummaryBloc.close();
  }

  Review? _review;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarWithBackButton(context: context, actions: [
        CommonTextButton(
          onPressed: () {
            Navigator.pushNamed(context, FeedbackScreen.route,
                arguments: FeedbackScreenArguments(
                    isFeedback: false, orderNumber: widget.bookingId));
          },
          child: Text(
            'Support',
            style: SizeConfig.kStyle16PrimaryColor,
          ),
          backgroundColor: Colors.white,
          buttonSemantics: 'Order Support Button',
        )
      ]),
      body: BlocBuilder<BookingSummaryBloc, BookingSummaryState>(
        bloc: _bookingSummaryBloc,
        builder: (context, state) {
          if (state is BookingSummaryLoading) {
            return Center(
              child: loadingAnimation(),
            );
          }
          if (state is BookingSummaryLoaded) {
            var bookingDetail = state.booking;

            var reviewState = state.booking.review;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Order Details',
                      style: SizeConfig.kStyle20W500,
                    ),
                    SizeConfig.kverticalMargin16,
                    StoreDetailTile(bookingDetail: bookingDetail),
                    SizeConfig.kverticalMargin24,
                    getBookingStatusTag(bookingDetail.status!),
                    SizeConfig.kverticalMargin24,
                    bookingDetail.status == BookingStatus.paymentSuccess
                        ? SizedBox(
                            child: AddToCalendarButton(
                                bookingDetail: bookingDetail),
                            width: 100.w,
                          )
                        : Container(),
                    Divider(
                      height: 32,
                    ),
                    bookingDetail.payment != null
                        ? PaymentSummaryWidget(bookingDetail: bookingDetail)
                        : Container(),
                    bookingDetail.status == BookingStatus.paymentSuccess
                        ? StoreContactWidget(
                            personToContact:
                                bookingDetail.store!.contactPersonName!,
                            phoneNumber:
                                bookingDetail.store!.contactPersonNumber!,
                            otp: bookingDetail.otp!,
                          )
                        : Container(),
                    Text('Booking Details',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: SizeConfig.kfontSize20)),
                    SizeConfig.kverticalMargin8,
                    DashedBookingBox(
                      bookingDetail: bookingDetail,
                      backgroundColor: Colors.white,
                    ),
                    SizeConfig.kverticalMargin16,
                    Divider(),
                    bookingDetail.status == BookingStatus.serviceCompleted
                        ? (_review != null || reviewState != null)
                            ? ReviewWidget(
                                rating: double.parse(
                                    getNotNullReview(_review, reviewState)!
                                        .rating!),
                                review: getNotNullReview(_review, reviewState)!
                                    .reviewDescription)
                            : RateServiceWidget(
                                bookingId: state.booking.bookingId!,
                                onReview: (review) {
                                  setState(() {
                                    _review = review;
                                  });
                                },
                                store: state.booking.store!,
                              )
                        : Container(),
                    widget.status == BookingStatus.paymentSuccess
                        ? CommonTextButton(
                            onPressed: () {
                              showCancelDialog(bookingDetail);
                              // Navigator.of(context).pushNamed(
                              //     CancelOrderScreen.route,
                              //     arguments: CancelOrderScreenArguments(
                              //         bookingId: bookingDetail.bookingId!));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                SizeConfig.kHorizontalMargin4,
                                Text(
                                  'Cancel Order',
                                  style: SizeConfig.kStyle14
                                      .copyWith(color: Colors.red),
                                )
                              ],
                            ),
                            backgroundColor: Colors.white,
                            buttonSemantics: 'Cancel Order',
                          )
                        : Container(),
                    Divider(),
                  ],
                ),
              ),
            );
          }
          if (state is BookingSummaryError) {
            return Center(
              child: ErrorScreen(
                ctaType: ErrorCTA.reload,
                onCTAPressed: () {
                  _bookingSummaryBloc
                      .add(GetBookingSummary(bookingId: widget.bookingId));
                },
              ),
            );
          }
          return Center(
            child: loadingAnimation(),
          );
        },
      ),
    );
  }

  Review? getNotNullReview(Review? review1, Review? review2) {
    if (review1 != null) {
      return review1;
    }
    return review2;
  }

  showCancelDialog(BookingDetailModel bookingDetail) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            actions: [
              CommonTextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(CancelOrderScreen.route,
                      arguments: CancelOrderScreenArguments(
                          bookingId: bookingDetail.bookingId!));
                },
                child: Text(
                  'proceed',
                  style: SizeConfig.kStyle14W500.copyWith(color: Colors.red),
                ),
                backgroundColor: Colors.white,
                border: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: BorderSide(color: Colors.red)),
                buttonSemantics: 'Order Cancel Proceed',
              ),
              CommonTextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'back',
                  style: SizeConfig.kStyle14W500.copyWith(color: Colors.white),
                ),
                backgroundColor: SizeConfig.kPrimaryColor,
                border: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                buttonSemantics: 'Order Cancel Back',
              )
            ],
            title: Text(
              'Confirm cancellation',
              style: SizeConfig.kStyle16Bold,
            ),
            content: Text(
              'Are you sure you want to cancel your order?',
              style: SizeConfig.kStyle14
                  .copyWith(color: SizeConfig.kGreyTextColor),
            ),
          );
        });
  }

  bool isCancellable(DateTime time) {
    if (time.difference(DateTime.now()) > Duration(hours: 12)) {
      return true;
    } else {
      return false;
    }
  }
}

class AddToCalendarButton extends StatelessWidget {
  final BookingDetailModel bookingDetail;
  const AddToCalendarButton({
    Key? key,
    required this.bookingDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        try {
          String description = '';

          bookingDetail.services!.forEach((element) {
            description = description + ', ' + element.service.toString();
          });
          final Event event = Event(
            title:
                'MotorWash booking for ${bookingDetail.vehicleModel!.brand} ${bookingDetail.vehicleModel!.model}',
            description: 'Services : ${description.substring(1)}',
            location: '${bookingDetail.store!.address}',
            startDate: bookingDetail.event!.startDateTime,
            endDate: bookingDetail.event!.endDateTime,
          );
          Add2Calendar.addEvent2Cal(event);
        } catch (e) {
          showSnackbar(context, 'No calendar app found');
        }
      },
      icon: Icon(Icons.calendar_today_outlined, color: Colors.white),
      label: Text(
        'Add event to calendar',
        style: TextStyle(color: Colors.white),
      ),
      style: ButtonStyle(
        backgroundColor:
            MaterialStateProperty.all(Theme.of(context).primaryColor),
        elevation: MaterialStateProperty.all(4),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
