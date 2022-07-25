import 'package:flutter/material.dart';
import 'package:themotorwash/theme_constants.dart';

class StoreHamperOfferWidget extends StatelessWidget {
  const StoreHamperOfferWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            border: Border.all(color: Color(0xffD3D3D3), width: 1),
            borderRadius: BorderRadius.circular(4),
            color: Color(0xffFFFBF7)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get a free hamper with every booking!',
                    style: SizeConfig.kStyle16Bold,
                  ),
                  // SizeConfig.kverticalMargin8,
                  Text('Yes it’s true. No coupon code required',
                      style: SizeConfig.kStyle12W500
                          .copyWith(color: SizeConfig.kGreyTextColor)),
                ],
              ),
            ),
            SizeConfig.kHorizontalMargin16,
            Image.asset('assets/images/hamper.png')
          ],
        ),
      ),
    );
  }
}
