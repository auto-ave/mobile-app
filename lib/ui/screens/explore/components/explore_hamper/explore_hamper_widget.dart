import 'package:flutter/material.dart';
import 'package:themotorwash/theme_constants.dart';

class ExploreHamperWidget extends StatelessWidget {
  const ExploreHamperWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 16, top: 16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xff61B2C2), width: 1),
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                  colors: [Color(0xffE4FAFF), Color(0xffEDFCFF)])),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free gift hamper on every order',
                      style: SizeConfig.kStyle24Bold
                          .copyWith(color: Color(0xff1A7686)),
                    ),
                    SizeConfig.kverticalMargin8,
                    Text('No terms and conditions only love❣️',
                        style: SizeConfig.kStyle12W500
                            .copyWith(color: Color(0xff688496))),
                    SizeConfig.kverticalMargin16,
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xff1A7686), shape: BoxShape.circle),
                      child: Icon(
                        Icons.arrow_right_alt_sharp,
                        color: Colors.white,
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    ),
                  ],
                ),
              ),
              SizeConfig.kHorizontalMargin16,
              Image.asset('assets/images/gift-box.png')
            ],
          ),
        ),
      ),
    );
  }
}
