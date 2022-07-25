import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:themotorwash/blocs/booking_summary/bloc/booking_summary_bloc.dart';
import 'package:themotorwash/blocs/review/review_bloc.dart';
import 'package:themotorwash/data/analytics/analytics_events.dart';
import 'package:themotorwash/data/models/booking_detail.dart';
import 'package:themotorwash/data/models/review.dart';
import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_detail/booking_detail.dart';
import 'package:themotorwash/ui/screens/booking_detail/components/store_detail_tile.dart';
import 'package:themotorwash/ui/screens/booking_summary/components/payable_amount_widget.dart';
import 'package:themotorwash/ui/screens/booking_summary/components/reaching_time_widget.dart';
import 'package:themotorwash/ui/screens/explore/explore_screen.dart';
import 'package:themotorwash/ui/screens/your_bookings/your_bookings_screen.dart';
import 'package:themotorwash/ui/widgets/badge.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/dashed_booking_box.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/utils/utils.dart';
import 'dart:developer' as d;

import 'package:url_launcher/url_launcher.dart';

class BookingSummaryScreen extends StatefulWidget {
  final bool isTransactionSuccessful;
  BookingSummaryScreen(
      {Key? key,
      required this.bookingId,
      required this.isTransactionSuccessful})
      : super(key: key);
  static final String route = "/bookingSummaryScreen";
  final String bookingId;

  @override
  _BookingSummaryScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    FlutterUxcam.occludeSensitiveScreen(false);
    return _BookingSummaryScreenState();
  }
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  // final TextStyle rightSideInfoPrimaryColor = TextStyle(
  //     color: SizeConfig.kPrimaryColor, fontWeight: FontWeight.w400, fontSize: SizeConfig.kfontSize12);
  // final TextStyle leftSideInfo =
  //     const TextStyle(fontWeight: FontWeight.w400, fontSize: SizeConfig.kfontSize12);
  // final TextStyle leftSide14W500 =
  //     TextStyle(fontWeight: FontWeight.w600, fontSize: SizeConfig.kfontSize14);
  // final TextStyle rightSide12W500 =
  //     TextStyle(fontWeight: FontWeight.w600, fontSize: SizeConfig.kfontSize12);

  late BookingSummaryBloc _bookingSummaryBloc;

  Review? _review;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // mixpanel?.track(
    // widget.isTransactionSuccessful
    //     ? BookingSuccessEvent().eventName()
    //     : BookingFailedEvent().eventName(),
    // properties: {'booking_id': widget.bookingId});
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

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
            context, YourBookingsScreen.route, (route) => false,
            arguments: YourBookingsScreenArguments(fromBookingSummary: true));
        return false;
      },
      child: Scaffold(
        appBar: getAppBarWithBackButton(
            context: context,
            title: Text(
              'Booking Summary',
              style: SizeConfig.kStyleAppBarTitle,
            )),
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
              debugPrint(state.booking.toString().substring(1000));
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizeConfig.kverticalMargin8,
                      PayableAmountWidget(
                          amount: bookingDetail.remainingAmount ?? ''),
                      SizeConfig.kverticalMargin8,
                      ReachingTimeWidget(
                          date: DateFormat('d MMMM')
                              .format(bookingDetail.event!.startDateTime),
                          time: DateFormat(DateFormat.HOUR24_MINUTE)
                              .format(bookingDetail.event!.startDateTime)),
                      SizeConfig.kverticalMargin32,
                      Row(
                        children: <Widget>[
                          Image.asset(widget.isTransactionSuccessful
                              ? 'assets/images/bookingConfirmedHands.png'
                              : 'assets/images/thumbs_down.png'),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.isTransactionSuccessful
                                      ? 'Booking Confirmed'
                                      : 'Booking Failed',
                                  style: TextStyle(
                                      color: widget.isTransactionSuccessful
                                          ? Theme.of(context).primaryColor
                                          : Colors.red,
                                      fontWeight: FontWeight.w700,
                                      fontSize: SizeConfig.kfontSize20),
                                ),
                                Text(
                                    widget.isTransactionSuccessful
                                        ? 'We have sent a receipt on your number and email'
                                        : 'There was an error processing the payment.\nAny amount deducted will be refunded in 3-5 business days.\nYour order isn’t booked.',
                                    style: TextStyle(
                                        fontSize: SizeConfig.kfontSize12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      SizedBox(
                        child: bookingDetail.status ==
                                BookingStatus.paymentSuccess
                            ? AddToCalendarButton(bookingDetail: bookingDetail)
                            : CommonTextButton(
                                onPressed: () =>
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        ExploreScreen.route, (route) => false),
                                child: Text(
                                  'Back to home',
                                  style: SizeConfig.kStyle16W500
                                      .copyWith(color: Colors.white),
                                ),
                                backgroundColor: SizeConfig.kPrimaryColor,
                                buttonSemantics: 'Back To Home Booking Summary',
                              ),
                        width: 100.w,
                      ),
                      Divider(
                        height: 32,
                      ),
                      bookingDetail.status != BookingStatus.paymentSuccess
                          ? Divider(
                              height: 32,
                            )
                          : Container(),
                      StoreDetailTile(bookingDetail: bookingDetail),
                      bookingDetail.status != BookingStatus.paymentSuccess
                          ? SizeConfig.kverticalMargin16
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
                      bookingDetail.payment != null &&
                              bookingDetail.status ==
                                  BookingStatus.paymentSuccess
                          ? PaymentSummaryWidget(bookingDetail: bookingDetail)
                          : Container(),
                      Text('Booking Details',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: SizeConfig.kfontSize20)),
                      SizeConfig.kverticalMargin16,
                      DashedBookingBox(
                        bookingDetail: bookingDetail,
                        backgroundColor: Colors.white,
                      ),
                      SizeConfig.kverticalMargin16,
                      Divider(),
                    ],
                  ),
                ),
              );
            }
            if (state is BookingSummaryError) {
              return Center(
                child: ErrorScreen(
                  ctaType: ErrorCTA.home,
                  // onCTAPressed: () {
                  //   _bookingSummaryBloc
                  //       .add(GetBookingSummary(bookingId: widget.bookingId));
                  // },
                ),
              );
            }
            return Center(
              child: loadingAnimation(),
            );
          },
        ),
      ),
    );
  }
}

class DetailsRowWidget extends StatelessWidget {
  final String? leftText;
  final String rightText;
  final TextStyle? leftStyle;
  final TextStyle rightStyle;
  final Widget? leftWidget;
  const DetailsRowWidget(
      {Key? key,
      this.leftText,
      required this.rightText,
      this.leftStyle,
      required this.rightStyle,
      this.leftWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        leftWidget != null
            ? Expanded(child: leftWidget!)
            : Expanded(
                child: Text(
                  leftText!,
                  style: leftStyle,
                ),
              ),
        SizeConfig.kHorizontalMargin8,
        Text(rightText, style: rightStyle),
      ],
    );
  }
}

class PaymentSummaryWidget extends StatelessWidget {
  final BookingDetailModel bookingDetail;
  const PaymentSummaryWidget({Key? key, required this.bookingDetail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: SizeConfig.kStyle16W500),
          SizeConfig.kverticalMargin16,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DetailsRowWidget(
                leftText: 'Total amount',
                rightText: '₹${bookingDetail.amount}',
                leftStyle:
                    SizeConfig.kStyle14.copyWith(fontWeight: FontWeight.w600),
                rightStyle: TextStyle(
                    color: SizeConfig.kPrimaryColor,
                    fontSize: SizeConfig.kfontSize14,
                    fontWeight: FontWeight.w500)),
          ),
          SizeConfig.kverticalMargin8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DetailsRowWidget(
                leftText: 'Booking amount paid',
                rightText: '₹${bookingDetail.payment!.amount}',
                leftStyle:
                    SizeConfig.kStyle14.copyWith(fontWeight: FontWeight.w600),
                rightStyle: TextStyle(
                    color: SizeConfig.kPrimaryColor,
                    fontSize: SizeConfig.kfontSize16,
                    fontWeight: FontWeight.w500)),
          ),
          SizeConfig.kverticalMargin8,
          // getDetailsRow(
          //     leftText: 'Taxes',
          //     rightText: '₹0',
          //     leftStyle: leftSideInfo,
          //     rightStyle: rightSide12W500),
          // SizeConfig.kverticalMargin8,
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Color(0xffDCECFF),
                borderRadius: BorderRadius.circular(4)),
            child: DetailsRowWidget(
                leftText: bookingDetail.status == BookingStatus.serviceCompleted
                    ? 'Amount paid at store'
                    : 'Amount to be paid at store',
                rightText: '₹${bookingDetail.remainingAmount}',
                leftStyle:
                    SizeConfig.kStyle14.copyWith(fontWeight: FontWeight.w600),
                rightStyle: TextStyle(
                    color: SizeConfig.kPrimaryColor,
                    fontSize: SizeConfig.kfontSize18,
                    fontWeight: FontWeight.w700)),
          ),
          Divider(
            height: 32,
          ),
        ]);
  }
}

class StoreContactWidget extends StatelessWidget {
  final String personToContact;
  final String phoneNumber;
  final String otp;
  const StoreContactWidget(
      {Key? key,
      required this.personToContact,
      required this.phoneNumber,
      required this.otp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizeConfig.kverticalMargin16,
        Row(
          children: [
            Text('OTP',
                style: SizeConfig.kStyle14.copyWith(
                  color: Colors.black,
                )),
            Spacer(),
            BadgeWidget(
              text: otp,
              textStyle: SizeConfig.kStyle16Bold.copyWith(color: Colors.white),
              backgroundColor: SizeConfig.kPrimaryColor,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
        SizeConfig.kverticalMargin8,
        GestureDetector(
          onTap: () {
            // mixpanel?.track('Person To Contact Click');
            final Uri telLaunchUri = Uri(
              scheme: 'tel',
              path: personToContact,
            );

            launch(telLaunchUri.toString());
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Person to contact: ',
                      style: SizeConfig.kStyle14.copyWith(
                        color: Colors.black,
                      )),
                  Spacer(),
                  Text(personToContact,
                      style: SizeConfig.kStyle16W500
                          .copyWith(color: SizeConfig.kPrimaryColor)),
                ],
              ),
              SizeConfig.kverticalMargin8,
              Row(
                children: [
                  Text('Contact Number: ',
                      style: SizeConfig.kStyle14.copyWith(
                        color: Colors.black,
                      )),
                  Spacer(),
                  Text(phoneNumber,
                      style: SizeConfig.kStyle16W500
                          .copyWith(color: SizeConfig.kPrimaryColor))
                ],
              ),
              Divider(
                height: 48,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class RateServiceWidget extends StatefulWidget {
  final Function(Review review) onReview;
  final String bookingId;
  final Store store;
  const RateServiceWidget({
    Key? key,
    required this.onReview,
    required this.bookingId,
    required this.store,
  }) : super(key: key);

  @override
  _RateServiceWidgetState createState() => _RateServiceWidgetState();
}

class _RateServiceWidgetState extends State<RateServiceWidget> {
  late ReviewBloc _reviewBloc;

  @override
  void initState() {
    super.initState();
    _reviewBloc =
        ReviewBloc(repository: RepositoryProvider.of<Repository>(context));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _reviewBloc.close();
  }

  double _rating = 0;

  TextEditingController reviewDescriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      bloc: _reviewBloc,
      listener: (context, state) {
        if (state is FailedToAddReview) {
          showSnackbar(context, 'Failed to add review. Something went wrong.');
        }
        if (state is ReviewAdded) {
          widget.onReview(state.review);
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate Service',
              style: SizeConfig.kStyle20W500,
            ),
            SizeConfig.kverticalMargin8,
            RatingBar(
              itemSize: 24,
              initialRating: 0,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              ratingWidget: RatingWidget(
                half: Container(),
                full: SvgPicture.asset(
                  'assets/icons/rating_star_filled.svg',
                  width: 24,
                ),
                empty: Image.asset(
                  'assets/icons/rating_star_raw.png',
                  width: 24,
                ),
              ),
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: (rating) {
                _rating = rating;
              },
            ),
            SizeConfig.kverticalMargin8,
            Text(
              'Add a review',
              style: SizeConfig.kStyle16,
            ),
            SizeConfig.kverticalMargin8,
            Container(
              height: 20.h,
              child: TextField(
                controller: reviewDescriptionController,
                style: TextStyle(fontSize: 18),
                maxLines: 100,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            BorderSide(color: SizeConfig.kPrimaryColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            BorderSide(color: SizeConfig.kPrimaryColor)),
                    hintText: "Write a review"),
              ),
            ),
            CommonTextButton(
              onPressed: () {
                if (_rating == 0) {
                  showSnackbar(context, 'Please rate from 1-5 stars');
                } else {
                  bool isOnlyRating =
                      reviewDescriptionController.text.trim() == "";
                  _reviewBloc.add(
                    AddReview(
                      review: ReviewEntity(
                        bookingId: widget.bookingId,
                        isOnlyRating: isOnlyRating,
                        store: widget.store.id,
                        reviewDescription: reviewDescriptionController.text,
                        rating: _rating.toString(),
                      ),
                    ),
                  );
                }
              },
              child: state is AddingReview
                  ? SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Post', style: TextStyle(color: Colors.white)),
              backgroundColor: Theme.of(context).primaryColor,
              buttonSemantics: 'Post Review',
            ),
          ],
        );
      },
    );
  }
}

class ReviewWidget extends StatelessWidget {
  final double rating;
  final String? review;
  const ReviewWidget({
    Key? key,
    required this.rating,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Review',
          style: SizeConfig.kStyle20W500,
        ),
        SizeConfig.kverticalMargin8,
        RatingBar(
          itemSize: 24,
          initialRating: rating,
          ignoreGestures: true,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          ratingWidget: RatingWidget(
            half: Container(),
            full: SvgPicture.asset(
              'assets/icons/rating_star_filled.svg',
            ),
            empty: SvgPicture.asset(
              'assets/icons/rating_star_raw.svg',
            ),
          ),
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          onRatingUpdate: (rating) {
            print(rating);
          },
        ),
        SizeConfig.kverticalMargin16,
        Text(
          review ?? "",
          style: SizeConfig.kStyle12,
        )
      ],
    );
  }
}
