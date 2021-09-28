import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:themotorwash/data/models/booking_detail.dart';
import 'package:themotorwash/theme_constants.dart';

class DashedBookingBox extends StatelessWidget {
  final BookingDetailModel bookingDetail;
  DashedBookingBox({
    Key? key,
    required this.bookingDetail,
  }) : super(key: key);
  final TextStyle rightSideInfoPrimaryColor = TextStyle(
      color: kPrimaryColor, fontWeight: FontWeight.w400, fontSize: kfontSize12);
  final TextStyle leftSideInfo =
      const TextStyle(fontWeight: FontWeight.w400, fontSize: kfontSize12);
  final TextStyle leftSide14SemiBold =
      TextStyle(fontWeight: FontWeight.w600, fontSize: kfontSize14);
  final TextStyle rightSide12SemiBold =
      TextStyle(fontWeight: FontWeight.w600, fontSize: kfontSize12);
  final DateFormat formatter = DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY);

  final DateFormat formatterTime = DateFormat('hh:mm a');

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      dashPattern: [8, 4],
      color: Theme.of(context).primaryColor,
      borderType: BorderType.Rect,
      child: Container(
        decoration: BoxDecoration(color: Color(0xffF3F8FF)),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getDetailsRow(
                leftText: 'OTP',
                rightText: bookingDetail.otp ?? 'N/A',
                leftStyle: leftSideInfo,
                rightStyle: rightSideInfoPrimaryColor),
            kverticalMargin8,
            getDetailsRow(
                leftText: 'Booking Id',
                rightText: bookingDetail.bookingId!,
                leftStyle: leftSideInfo,
                rightStyle: rightSideInfoPrimaryColor),
            kverticalMargin8,
            getDetailsRow(
                leftText: 'Car Model:',
                rightText: 'BMW X4',
                leftStyle: leftSideInfo,
                rightStyle: rightSideInfoPrimaryColor),
            kverticalMargin8,
            getDetailsRow(
                leftText: 'Scheduled on',
                rightText: formatter.format(bookingDetail.event!.startDateTime),
                leftStyle: leftSideInfo,
                rightStyle: rightSideInfoPrimaryColor),
            kverticalMargin8,
            Divider(),
            kverticalMargin8,
            getDetailsRow(
                leftText: 'Time:',
                rightText:
                    '${formatterTime.format(bookingDetail.event!.startDateTime)} to ${formatterTime.format(bookingDetail.event!.endDateTime)}',
                leftStyle: leftSideInfo,
                rightStyle: rightSideInfoPrimaryColor),
            kverticalMargin8,
            ...(bookingDetail.services!
                .map((e) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        getDetailsRow(
                            leftText: e.service,
                            rightText: '₹${e.price}',
                            leftStyle: leftSide14SemiBold,
                            rightStyle: rightSide12SemiBold),
                        kverticalMargin8
                      ],
                    ))
                .toList()),
            Divider(),
            kverticalMargin8,
            bookingDetail.payment != null
                ? getPaymentSummary(bookingDetail)
                : Container(),
            kverticalMargin8,
          ],
        ),
      ),
    );
  }

  Widget getPaymentSummary(BookingDetailModel bookingDetail) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary', style: leftSide14SemiBold),
          kverticalMargin8,
          getDetailsRow(
              leftText: 'Item Total',
              rightText: '₹${bookingDetail.payment!.amount}',
              leftStyle: leftSideInfo,
              rightStyle: rightSide12SemiBold),
          kverticalMargin8,
          getDetailsRow(
              leftText: 'Taxes',
              rightText: '₹0',
              leftStyle: leftSideInfo,
              rightStyle: rightSide12SemiBold),
          kverticalMargin8,
          getDetailsRow(
              leftText: 'Grand Total',
              rightText: '₹${bookingDetail.payment!.amount}',
              leftStyle: leftSideInfo.copyWith(
                  color: kPrimaryColor,
                  fontSize: kfontSize16,
                  fontWeight: FontWeight.w600),
              rightStyle: rightSideInfoPrimaryColor.copyWith(
                  color: Colors.black,
                  fontSize: kfontSize16,
                  fontWeight: FontWeight.w600)),
        ]);
  }

  Widget getDetailsRow(
      {required String leftText,
      required String rightText,
      required TextStyle leftStyle,
      required TextStyle rightStyle}) {
    return Row(
      children: <Widget>[
        Text(
          leftText,
          style: leftStyle,
        ),
        Spacer(),
        Text(rightText, style: rightStyle),
      ],
    );
  }
}
