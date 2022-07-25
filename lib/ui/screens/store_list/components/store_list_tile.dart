import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:themotorwash/data/analytics/analytics_events.dart';
import 'package:themotorwash/data/models/price_time_list_model.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/store_detail/store_detail_screen.dart';
import 'package:themotorwash/ui/widgets/badge.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/shimmer_placeholder.dart';
import 'package:themotorwash/utils/utils.dart';

class StoreListTile extends StatelessWidget {
  final String imageURL;
  final String storeName;
  final String distance;
  final String? rating;
  final String startingFrom;
  final String storeSlug;
  final bool isNew;
  final String? serviceTag;
  final String address;
  final List<PriceTimeListModel>? taggedServices;

  const StoreListTile(
      {required this.distance,
      required this.imageURL,
      required this.rating,
      required this.storeName,
      required this.startingFrom,
      required this.storeSlug,
      required this.isNew,
      required this.address,
      this.serviceTag,
      this.taggedServices});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // mixpanel?.track(SearchStoreClick().eventName());
        Navigator.of(context).pushNamed(StoreDetailScreen.route,
            arguments: StoreDetailArguments(
                storeSlug: storeSlug, serviceTag: serviceTag));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Container(
          // padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          // decoration: BoxDecoration(
          //     border: Border.all(
          //       color: SizeConfig.kPrimaryColor,
          //     ),
          //     borderRadius: BorderRadius.circular(4)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    placeholder: (_, __) {
                      return Container(
                        child: ShimmerPlaceholder(),
                        width: 30.w,
                        height: 30.w,
                      );
                    },
                    imageUrl: imageURL,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.5),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0)),
                      ),
                      padding: EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/location.svg',
                            color: Colors.white,
                          ),
                          SizeConfig.kHorizontalMargin8,
                          Text(
                            distance,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SizeConfig.kStyle16W500,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: "$address",
                          style: TextStyle(
                            color: SizeConfig.kGreyTextColor.withOpacity(.8),
                          ),
                        ),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    !isNew
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                rating ?? '',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                            ],
                          )
                        : BadgeWidget(
                            text: 'New',
                            // height: 5.w,
                            // width: 10.w,
                            backgroundColor: SizeConfig.kPrimaryColor,
                            textStyle: SizeConfig.kStyle12.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                    SizedBox(
                      height: 8,
                    ),
                    taggedServices != null
                        ? Container(
                            padding: EdgeInsets.all(4),
                            // color: Colors.amber,
                            decoration: BoxDecoration(
                                color: Color(0xffEAF4FF),
                                borderRadius: BorderRadius.circular(4)),
                            // height: 50,
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: '${taggedServices!.first.service} @ ',
                                  style: SizeConfig.kStyle12.copyWith(
                                      color: SizeConfig.kGreyTextColor)),
                              TextSpan(
                                  text:
                                      '${taggedServices!.first.price.toString().rupees()}',
                                  style: SizeConfig.kStyle14Bold.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: SizeConfig.kPrimaryColor))
                            ])))
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'dart:ffi';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:hive_flutter/adapters.dart';
// import 'package:themotorwash/data/analytics/analytics_events.dart';
// import 'package:themotorwash/data/models/price_time_list_model.dart';
// import 'package:themotorwash/main.dart';
// import 'package:themotorwash/navigation/arguments.dart';
// import 'package:themotorwash/theme_constants.dart';
// import 'package:themotorwash/ui/screens/store_detail/store_detail_screen.dart';
// import 'package:themotorwash/ui/widgets/badge.dart';
// import 'package:themotorwash/ui/widgets/loading_widgets/shimmer_placeholder.dart';
// import 'package:themotorwash/utils/utils.dart';

// class StoreListTile extends StatelessWidget {
//   final String imageURL;
//   final String storeName;
//   final String distance;
//   final String? rating;
//   final String startingFrom;
//   final String storeSlug;
//   final bool isNew;
//   final String? serviceTag;
//   final String address;
//   final List<PriceTimeListModel>? taggedServices;

//   const StoreListTile(
//       {required this.distance,
//       required this.imageURL,
//       required this.rating,
//       required this.storeName,
//       required this.startingFrom,
//       required this.storeSlug,
//       required this.isNew,
//       required this.address,
//       this.serviceTag,
//       this.taggedServices});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: () {
//         // mixpanel?.track(SearchStoreClick().eventName());
//         Navigator.of(context).pushNamed(StoreDetailScreen.route,
//             arguments: StoreDetailArguments(
//                 storeSlug: storeSlug, serviceTag: serviceTag));
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
//         child: Container(
//           // padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
//           // decoration: BoxDecoration(
//           //     border: Border.all(
//           //       color: SizeConfig.kPrimaryColor,
//           //     ),
//           //     borderRadius: BorderRadius.circular(4)),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Stack(
//                 children: [
//                   CachedNetworkImage(
//                     placeholder: (_, __) {
//                       return Container(
//                         child: ShimmerPlaceholder(),
//                         width: 30.w,
//                         height: 30.w,
//                       );
//                     },
//                     imageUrl: imageURL,
//                     imageBuilder: (context, imageProvider) => Container(
//                       width: 30.w,
//                       height: 30.w,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                         image: DecorationImage(
//                             image: imageProvider, fit: BoxFit.cover),
//                       ),
//                     ),
//                   ),
//                   // Positioned(
//                   //   bottom: 0,
//                   //   right: 0,
//                   //   left: 0,
//                   //   child: Container(
//                   //     decoration:
//                   //         BoxDecoration(color: Colors.black.withOpacity(.5)),
//                   //     padding: EdgeInsets.all(4),
//                   //     child: Row(
//                   //       mainAxisAlignment: MainAxisAlignment.center,
//                   //       // mainAxisSize: MainAxisSize.min,
//                   //       children: [
//                   //         SvgPicture.asset(
//                   //           'assets/icons/location.svg',
//                   //           color: Colors.white,
//                   //         ),
//                   //         SizeConfig.kHorizontalMargin8,
//                   //         Text(
//                   //           distance,
//                   //           style: TextStyle(fontSize: 14, color: Colors.white),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//               SizedBox(
//                 width: 12,
//               ),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       storeName,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: SizeConfig.kStyle16W500,
//                     ),
//                     SizedBox(
//                       height: 8,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       // mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SvgPicture.asset(
//                           'assets/icons/location.svg',
//                         ),
//                         SizeConfig.kHorizontalMargin8,
//                         Text(
//                           distance,
//                           style: TextStyle(
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Text.rich(
//                     //   TextSpan(children: [
//                     //     TextSpan(
//                     //       text: "$address",
//                     //       style: TextStyle(
//                     //         color: SizeConfig.kGreyTextColor.withOpacity(.8),
//                     //       ),
//                     //     ),
//                     //   ]),
//                     //   maxLines: 2,
//                     //   overflow: TextOverflow.ellipsis,
//                     // ),
//                     SizedBox(
//                       height: 8,
//                     ),
//                     !isNew
//                         ? Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.star,
//                                 color: Colors.amber,
//                                 size: 16,
//                               ),
//                               SizedBox(
//                                 width: 8,
//                               ),
//                               Text(
//                                 rating ?? '',
//                                 style: TextStyle(fontSize: 14),
//                               ),
//                               SizedBox(
//                                 width: 8,
//                               ),
//                             ],
//                           )
//                         : BadgeWidget(
//                             text: 'New',
//                             height: 5.w,
//                             width: 10.w,
//                             backgroundColor: SizeConfig.kPrimaryColor,
//                             textStyle: SizeConfig.kStyle12.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                     SizedBox(
//                       height: 8,
//                     ),
//                     taggedServices != null
//                         ? Container(
//                             padding: EdgeInsets.all(4),
//                             // color: Colors.amber,
//                             decoration: BoxDecoration(
//                                 color: Color(0xffEAF4FF),
//                                 borderRadius: BorderRadius.circular(4)),
//                             // height: 50,
//                             child: Text.rich(TextSpan(children: [
//                               TextSpan(
//                                   text: '${taggedServices!.first.service} @ ',
//                                   style: SizeConfig.kStyle12.copyWith(
//                                       color: SizeConfig.kGreyTextColor)),
//                               TextSpan(
//                                   text:
//                                       '${taggedServices!.first.price.toString().rupees()}',
//                                   style: SizeConfig.kStyle14Bold.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                       color: SizeConfig.kPrimaryColor))
//                             ])))
//                         : SizedBox.shrink(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
