import 'package:flutter/material.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/utils/utils.dart';

class PayableAmountWidget extends StatelessWidget {
  final String amount;
  const PayableAmountWidget({Key? key, required this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          border: Border.all(color: Color(0xff8DB495), width: 1),
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              // Color(0xffDAFFE2),
              Color(0xffDEF2F9),
              Color(0xffE4FFEA),
            ],
          )),
      child: Row(
        children: [
          // SizeConfig.kHorizontalMargin16,
          Expanded(
            child: Text.rich(TextSpan(children: [
              TextSpan(
                text: 'Amount Payable at Store ',
                style: SizeConfig.kStyle16.copyWith(fontSize: 18),
              ),
              TextSpan(
                  text: amount.rupees(),
                  style: SizeConfig.kStyle20Bold.copyWith(fontSize: 18))
            ])),
            // SizeConfig.kverticalMargin8,
          ),
          Image.asset('assets/images/money.png'),
        ],
      ),
    );
  }
}
