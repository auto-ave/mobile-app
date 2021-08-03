import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:themotorwash/theme_constants.dart';

class StoreInfo extends StatelessWidget {
  final String address;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final String serviceStartsAt;
  const StoreInfo({
    Key? key,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.serviceStartsAt,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset('assets/icons/location.svg'),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: Text(
              address + "asdasdadsasdasdasdasd",
              overflow: TextOverflow.ellipsis,
            ))
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            SvgPicture.asset('assets/icons/time.svg'),
            SizedBox(
              width: 8,
            ),
            Text(
                "${openingTime.format(context)} to ${closingTime.format(context)}")
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            SvgPicture.asset('assets/icons/calendar.svg'),
            SizedBox(
              width: 8,
            ),
            Text("Monday - Saturday")
          ],
        ),
        SizedBox(
          height: 8,
        ),
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(children: [
            TextSpan(
              text: "services start @ ",
              style: TextStyle(
                color: Color(0xff8D8D8D),
              ),
            ),
            TextSpan(
              text: serviceStartsAt,
              style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),
      ],
    );
  }
}