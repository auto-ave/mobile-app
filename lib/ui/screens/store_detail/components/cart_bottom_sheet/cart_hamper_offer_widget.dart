import 'package:flutter/material.dart';
import 'package:themotorwash/theme_constants.dart';

class CartHamperOfferWidget extends StatelessWidget {
  const CartHamperOfferWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xffAB7D00), width: 1),
            borderRadius: BorderRadius.circular(4),
            color: Color(0xffFFE8AA)),
        child: Row(
          children: [
            Image.asset('assets/images/gift-box-cart.png'),
            // SizeConfig.kHorizontalMargin16,
            Expanded(
              child: Text(
                'Get a free hamper with every booking!',
                style: SizeConfig.kStyle14W500,
              ),
              // SizeConfig.kverticalMargin8,
            ),
          ],
        ),
      ),
    );
  }
}
