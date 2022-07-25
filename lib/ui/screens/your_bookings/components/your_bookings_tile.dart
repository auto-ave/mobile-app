import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:themotorwash/data/models/booking_detail.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_detail/booking_detail.dart';
import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
import 'package:themotorwash/ui/widgets/badge.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/shimmer_placeholder.dart';

class YourBookingTile extends StatefulWidget {
  final String? otp;
  final String storeName;
  final String address;
  final String total;
  final List<String> serviceNames;
  final String imageUrl;
  final DateTime bookedAt;
  final String bookingId;
  final BookingStatus status;
  final DateTime scheduledOn;
  const YourBookingTile({
    Key? key,
    this.otp,
    required this.storeName,
    required this.address,
    required this.total,
    required this.serviceNames,
    required this.imageUrl,
    required this.bookedAt,
    required this.bookingId,
    required this.status,
    required this.scheduledOn,
  }) : super(key: key);

  @override
  _YourBookingTileState createState() => _YourBookingTileState();
}

class _YourBookingTileState extends State<YourBookingTile> {
  DateFormat dateFormatter = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY);
  DateFormat timeFormatter = DateFormat('hh:mm a');
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // mixpanel?.track('Your Booking Tile Click');
            Navigator.pushNamed(context, BookingDetailScreen.route,
                arguments: BookingDetailScreenArguments(
                    bookingId: widget.bookingId, status: widget.status));
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 4),
                      blurRadius: 16,
                      color: Color.fromRGBO(0, 0, 0, 0.16))
                ]),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: <Widget>[
                  Hero(
                    tag: widget.bookingId,
                    child: CachedNetworkImage(
                      placeholder: (_, __) {
                        return ShimmerPlaceholder();
                      },
                      imageUrl: widget.imageUrl,
                      imageBuilder: (ctx, imageProvider) {
                        return Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )),
                        );
                      },
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizeConfig.kHorizontalMargin8,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(widget.storeName, style: SizeConfig.kStyle16W500),
                        Text(
                          widget.address,
                          style: SizeConfig.kStyle12
                              .copyWith(color: Color(0xff888888)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                  SizeConfig.kHorizontalMargin8,
                  Text('₹${widget.total}', style: SizeConfig.kStyle16W500)
                ]),
                Divider(),
                getBookingStatusTag(widget.status),
                SizeConfig.kverticalMargin8,
                Text(
                  'I T E M S',
                  style: SizeConfig.kStyle12W500
                      .copyWith(color: Color(0xff888888)),
                ),
                SizeConfig.kverticalMargin4,
                ...(widget.serviceNames.map((e) => getBulletText(e)).toList()),
                SizeConfig.kverticalMargin4,
                Text(
                  'More Info',
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                ),
                Divider(),
                SizeConfig.kverticalMargin8,
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SCHEDULED ON',
                            style: SizeConfig.kStyle12W500.copyWith(
                                letterSpacing: 2.16, color: Color(0xff888888)),
                          ),
                          SizeConfig.kverticalMargin8,
                          Text(dateFormatter.format(widget.scheduledOn) +
                              " at " +
                              timeFormatter.format(widget.scheduledOn)),
                          SizeConfig.kverticalMargin8,
                        ],
                      ),
                    ),
                    SizeConfig.kHorizontalMargin8,
                    widget.status == BookingStatus.paymentSuccess
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'OTP',
                                style: SizeConfig.kStyle12W500.copyWith(
                                    letterSpacing: 2.16,
                                    color: Color(0xff888888)),
                              ),
                              SizeConfig.kverticalMargin8,
                              BadgeWidget(
                                text: widget.otp!,
                                textStyle: SizeConfig.kStyle12.copyWith(
                                    color: SizeConfig.kPrimaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizeConfig.kverticalMargin8,
                            ],
                          )
                        : Container(),
                  ],
                ),
                // Row(
                //   children: <Widget>[
                //     getButton(
                //         borderAndTextColor: Theme.of(context).primaryColor,
                //         buttonText: 'Reschedule',
                //         onPressed: () {}),
                //     Spacer(),
                //     getButton(
                //         borderAndTextColor: Color(0xffDC1313),
                //         buttonText: 'Cancel',
                //         onPressed: () {}),
                //   ],
                // ),
              ],
            ),
          ),
        ));
  }

  Widget getButton(
      {required String buttonText,
      required Color borderAndTextColor,
      required onPressed}) {
    return Expanded(
      // width: MediaQuery.of(context).size.width * .3,
      child: TextButton(
        onPressed: () {},
        child: Text(
          buttonText,
          style: TextStyle(color: borderAndTextColor),
        ),
        style: ButtonStyle(
          side: MaterialStateProperty.all(
            BorderSide(
              color: borderAndTextColor,
              width: 1,
            ),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  Widget getBulletText(String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [Text("\u2022 $text"), SizeConfig.kverticalMargin4],
    );
  }
}

Widget getBookingStatusTag(BookingStatus status) {
  var colors = getBookingStatusTagColor(status);
  var text = getBookingStatusTagText(status);
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: Text(
      text,
      style: SizeConfig.kStyle14W500
          .copyWith(color: colors.textColor, letterSpacing: 1.2),
    ),
    decoration: BoxDecoration(
        color: colors.backgroundColor, borderRadius: BorderRadius.circular(2)),
  );
}

BookingStatusTagColors getBookingStatusTagColor(BookingStatus status) {
  final BookingStatusTagColors redShade = BookingStatusTagColors(
      textColor: Color(0xffE94235), backgroundColor: Color(0xffFFD6D6));
  final BookingStatusTagColors greenShade = BookingStatusTagColors(
      textColor: Color(0xff35B559), backgroundColor: Color(0xffD6FFE1));
  switch (status) {
    case BookingStatus.cancellationRequestApproved:
      return greenShade;
    case BookingStatus.cancellationRequestRejected:
      return redShade;
    case BookingStatus.cancellationRequestSubmitted:
      return greenShade;
    case BookingStatus.paymentSuccess:
      return greenShade;
    case BookingStatus.paymentFailed:
      return redShade;
    case BookingStatus.notAttended:
      return redShade;
    case BookingStatus.serviceStarted:
      return greenShade;
    case BookingStatus.serviceCompleted:
      return greenShade;
    case BookingStatus.initiated:
      return greenShade;
    case BookingStatus.successWithoutPayment:
      return greenShade;
    default:
      return redShade;
  }
}

String getBookingStatusTagText(BookingStatus status) {
  switch (status) {
    case BookingStatus.cancellationRequestApproved:
      return 'CANCELLATION APPROVED';
    case BookingStatus.cancellationRequestRejected:
      return 'CANCELLATION REJECTED';
    case BookingStatus.cancellationRequestSubmitted:
      return 'CANCELLATION REQUESTED';
    case BookingStatus.paymentSuccess:
      return 'PAYMENT DONE';
    case BookingStatus.paymentFailed:
      return 'PAYMENT FAILED';
    case BookingStatus.notAttended:
      return 'NOT ATTENDED';
    case BookingStatus.serviceStarted:
      return 'SERVICE STARTED';
    case BookingStatus.serviceCompleted:
      return 'COMPLETED';
    case BookingStatus.successWithoutPayment:
      return 'BOOKING CONFIRMED';
    case BookingStatus
        .initiated: //TODO: Need to eliminate this status becuase it is of no use to the user
      return 'INITIATED';
    default:
      return 'STATUS UNAVAILABLE';
  }
}

class BookingStatusTagColors {
  final Color textColor;
  final Color backgroundColor;
  BookingStatusTagColors({
    required this.textColor,
    required this.backgroundColor,
  });
}
