import 'package:flutter/material.dart';
import 'package:themotorwash/theme_constants.dart';

class ReachingTimeWidget extends StatelessWidget {
  final String date;
  final String time;
  const ReachingTimeWidget({Key? key, required this.date, required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xffDDDDDD), width: 1),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white),
      child: Row(
        children: [
          // SizeConfig.kHorizontalMargin16,
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text: 'Reach the store on ',
                style: SizeConfig.kStyle16.copyWith(fontSize: 18),
              ),
              TextSpan(
                  text: date,
                  style: SizeConfig.kStyle20Bold.copyWith(fontSize: 18)),
              TextSpan(
                  text: ' at ',
                  style: SizeConfig.kStyle16.copyWith(fontSize: 18)),
              TextSpan(
                  text: time,
                  style: SizeConfig.kStyle20Bold.copyWith(fontSize: 18)),
            ])),
            // SizeConfig.kverticalMargin8,
          ),
          Image.asset('assets/images/clock.png'),
        ],
      ),
    );
  }
}
