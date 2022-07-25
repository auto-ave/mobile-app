import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:themotorwash/blocs/cart/cart_function_bloc.dart';
import 'package:themotorwash/blocs/global_cart/bloc/global_cart_bloc.dart';
import 'package:themotorwash/blocs/offer_apply/bloc/offer_apply_bloc.dart';
import 'package:themotorwash/blocs/order_review/order_review_bloc.dart';
import 'package:themotorwash/data/models/cart.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/booking_summary/booking_summary_screen.dart';
import 'package:themotorwash/ui/screens/offer_selection/offer_selection.dart';
import 'package:themotorwash/ui/screens/slot_select/slot_select_screen.dart';
import 'package:themotorwash/ui/screens/store_detail/components/cart_bottom_sheet/cart_hamper_offer_widget.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/utils/utils.dart';

class CartBottomSheet extends StatefulWidget {
  CartBottomSheet({Key? key}) : super(key: key);

  @override
  _CartBottomSheetState createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  late CartFunctionBloc _cartFunctionBloc;
  late CartModel cart;
  late OrderReviewBloc _orderReviewBloc;
  late GlobalCartBloc _globalCartBloc;
  late final OfferApplyBloc _offerApplyBloc;
  @override
  void initState() {
    super.initState();
    _orderReviewBloc = BlocProvider.of<OrderReviewBloc>(context, listen: false);
    _cartFunctionBloc = BlocProvider.of<CartFunctionBloc>(context);
    _globalCartBloc = BlocProvider.of<GlobalCartBloc>(context);
    _offerApplyBloc = OfferApplyBloc(
        repository: RepositoryProvider.of<Repository>(context),
        globalCartBloc: _globalCartBloc);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _offerApplyBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocListener<OfferApplyBloc, OfferApplyState>(
          bloc: _offerApplyBloc,
          listener: (context, state) {
            // TODO: implement listener
            if (state is OfferApplySuccess) {
              if (state.offerSuccessType == OfferSuccess.apply) {
                Navigator.pop(context);
                showSnackbar(context, 'Offer applied');
              } else if (state.offerSuccessType == OfferSuccess.remove) {
                Navigator.pop(context);
                showSnackbar(context, 'Offer removed');
              }
            } else if (state is OfferApplyError) {
              if (state.offerErrorType == OfferSuccess.apply) {
                Navigator.pop(context);
                showSnackbar(context, 'Failed to apply offer');
              } else if (state.offerErrorType == OfferSuccess.remove) {
                Navigator.pop(context);
                showSnackbar(context, 'Failed to remove offer');
              }
            }
          },
          child: BlocConsumer<CartFunctionBloc, CartFunctionState>(
              bloc: _cartFunctionBloc,
              listener: (_, state) {
                if (state is CartItemAdded ||
                    state is CartItemDeleted ||
                    state is CartLoaded) {
                  if (state is CartItemAdded) {
                    if (state.cart.items!.isEmpty) {
                      Navigator.pop(context);
                    }
                  }
                  if (state is CartItemDeleted) {
                    if (state.cart.items!.isEmpty) {
                      Navigator.pop(context);
                    }
                  }
                  if (state is CartLoaded) {
                    if (state.cart.items!.isEmpty) {
                      Navigator.pop(context);
                    }
                  }
                }
              },
              builder: (context, cartFunctionState) {
                return BlocConsumer(
                    bloc: _globalCartBloc,
                    builder: (context, globalState) {
                      if (globalState is CartSetSuccess) {
                        cart = globalState.cart;
                        return cart.items!.isEmpty
                            ? Container(
                                height: 30.h,
                                child: Center(
                                    child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Empty Cart',
                                      style: SizeConfig.kStyle16W500,
                                    ),
                                    SizeConfig.kHorizontalMargin8,
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.black,
                                    )
                                  ],
                                )),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: SizeConfig.kPrimaryColor,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Expanded(
                                          child: Text(cart.store!.name!,
                                              style: SizeConfig.kStyle16W500),
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  ...(cart.itemsObj!.map((e) {
                                    return CartItemTile(
                                        isLoading: cartFunctionState
                                                is CartFunctionLoading &&
                                            cartFunctionState.itemId
                                                .contains(e.id),
                                        cartFunctionBloc: _cartFunctionBloc,
                                        itemId: e.id,
                                        price: e.price!.toString(),
                                        service: e.service!,
                                        mrp: e.mrp!.toString(),
                                        timeInterval:
                                            e.timeInterval!.toString());
                                  }).toList()),
                                  SizeConfig.kverticalMargin24,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: Text(
                                      'Offers and Benifits',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),

                                  // SizedBox(
                                  //   height: 24,
                                  // ),
                                  // cart.offer != null
                                  //     ? Container(
                                  //         padding: EdgeInsets.symmetric(
                                  //             horizontal: 20, vertical: 16),
                                  //         decoration: BoxDecoration(
                                  //             color: Color(0xffF3F8FF)),
                                  //         child: Column(
                                  //           children: [
                                  //             DetailsRowWidget(
                                  //                 leftText: 'Item total',
                                  //                 rightText:
                                  //                     cart.subTotal!.rupees(),
                                  //                 leftStyle: SizeConfig.kStyle14
                                  //                     .copyWith(
                                  //                         color: Color(
                                  //                             0xff888888)),
                                  //                 rightStyle:
                                  //                     SizeConfig.kStyle14W500),
                                  //             SizeConfig.kverticalMargin8,
                                  //             DetailsRowWidget(
                                  //                 leftWidget: RichText(
                                  //                     text: TextSpan(children: [
                                  //                   TextSpan(
                                  //                       text:
                                  //                           'Promocode discount ',
                                  //                       style: SizeConfig
                                  //                           .kStyle14
                                  //                           .copyWith(
                                  //                               color: Color(
                                  //                                   0xff888888))),
                                  //                   TextSpan(
                                  //                       text:
                                  //                           '(${cart.offer!.code!})',
                                  //                       style: SizeConfig
                                  //                           .kStyle14
                                  //                           .copyWith(
                                  //                               color: Color(
                                  //                                   0xff6326C7)))
                                  //                 ])),
                                  //                 rightText:
                                  //                     '- ${cart.discount!.rupees()}',
                                  //                 rightStyle: SizeConfig
                                  //                     .kStyle14W500
                                  //                     .copyWith(
                                  //                         color: Color(
                                  //                             0xff35B549))),
                                  //           ],
                                  //         ))
                                  //     : SizedBox.shrink(),
                                  CartHamperOfferWidget(),
                                  SizeConfig.kverticalMargin24,
                                  SafeArea(
                                    child: GestureDetector(
                                      onTap: () {
                                        _orderReviewBloc
                                            .add(SetCart(cart: cart));
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                            context, SlotSelectScreen.route,
                                            arguments:
                                                SlotSelectScreenArguments(
                                                    isMultiDay:
                                                        cart.isMultiDay!,
                                                    cartTotal: cart.total!,
                                                    cardId:
                                                        cart.id!.toString()));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: SizeConfig.kPrimaryColor,
                                            boxShadow: [
                                              BoxShadow(
                                                  blurRadius: 4,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, .08),
                                                  offset: Offset(0, -2))
                                            ]),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 16),
                                        child: Row(
                                          children: <Widget>[
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Text(
                                                  'T O T A L',
                                                  style: SizeConfig.kStyle12
                                                      .copyWith(
                                                          color: Colors.white),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text('₹${cart.total}',
                                                    style: SizeConfig
                                                        .kStyle20W500
                                                        .copyWith(
                                                            color:
                                                                Colors.white)),
                                              ],
                                            ),
                                            Spacer(),
                                            Row(
                                              children: [
                                                CommonTextButton(
                                                  onPressed: () {
                                                    _orderReviewBloc.add(
                                                        SetCart(cart: cart));
                                                    Navigator.pop(context);
                                                    Navigator.pushNamed(context,
                                                        SlotSelectScreen.route,
                                                        arguments:
                                                            SlotSelectScreenArguments(
                                                                isMultiDay: cart
                                                                    .isMultiDay!,
                                                                cartTotal:
                                                                    cart.total!,
                                                                cardId: cart.id!
                                                                    .toString()));
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('Proceed',
                                                          style: SizeConfig
                                                              .kStyle16W500
                                                              .copyWith(
                                                                  color: SizeConfig
                                                                      .kPrimaryColor)),
                                                    ],
                                                  ),
                                                  backgroundColor: Colors.white,
                                                  buttonSemantics:
                                                      'Cart Select Slot',
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                                ),
                                              ],
                                            )
                                            // TextButton(
                                            //   child: Text('Select Slot',
                                            //       style: TextStyle(color: Colors.white)),
                                            //   onPressed: () {
                                            //     _orderReviewBloc.add(SetCart(cart: cart));
                                            //     Navigator.pushNamed(
                                            //         context, SlotSelectScreen.route,
                                            //         arguments: SlotSelectScreenArguments(
                                            //             cartTotal: cart.total!,
                                            //             cardId: cart.id!.toString()));
                                            //   },
                                            //   style: ButtonStyle(
                                            //       backgroundColor: MaterialStateProperty.all(
                                            //           Theme.of(context).primaryColor)),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              );
                      }
                      return Container(
                        child: Center(
                          child: loadingAnimation(),
                        ),
                        height: 300,
                      );
                    },
                    listener: (context, state) {});
              })),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final String? service;
  final String? timeInterval;
  final String? price;
  final int? itemId;
  final bool isLoading;
  final CartFunctionBloc cartFunctionBloc;
  final String? mrp;
  const CartItemTile(
      {Key? key,
      this.service,
      this.timeInterval,
      this.price,
      this.itemId,
      required this.isLoading,
      required this.cartFunctionBloc,
      required this.mrp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Row(children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service!,
                      style: SizeConfig.kStyle16,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text('$timeInterval')
                      ],
                    )
                  ],
                ),
              ),
              if (mrp != 0.toString())
                Text.rich(
                  TextSpan(
                    children: <TextSpan>[
                      new TextSpan(
                        text: '₹ $mrp',
                        style: new TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      new TextSpan(
                          text: ' ₹ $price',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: SizeConfig.kfontSize16)),
                    ],
                  ),
                )
              else
                Text(
                  '₹ $price',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: SizeConfig.kfontSize16),
                ),
              SizedBox(
                width: 16,
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: CommonTextButton(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  border: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Color(0xffDC1313),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onPressed: () {
                    cartFunctionBloc.add(DeleteItemFromCart(itemId: itemId!));
                  },
                  buttonSemantics: 'Cart Delete Item',
                  child: isLoading
                      ? SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : FittedBox(
                          child: Text(
                            'Remove',
                            style: TextStyle(color: Color(0xffDC1313)),
                          ),
                        ),
                ),
              )
            ])),
        SizeConfig.kverticalMargin8,
        Divider(
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}

// class ViewOffersWidget extends StatelessWidget {
//   const ViewOffersWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         FaIcon(
//           FontAwesomeIcons.moneyBillAlt,
//           color: Colors.green,
//         ),
//         SizedBox(
//           width: 8,
//         ),
//         Expanded(
//             child: cart.offer != null
//                 ? Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         '${cart.offer!.code} (applied)',
//                         style: SizeConfig.kStyle14Bold
//                             .copyWith(color: Colors.deepPurple),
//                       ),
//                       SizeConfig.kHorizontalMargin4,
//                       GestureDetector(
//                         onTap: () {
//                           _offerApplyBloc.add(RemoveOffer());
//                           // mixpanel?.track(
//                           // 'Offer Remove');
//                         },
//                         child: Icon(
//                           Icons.remove_circle_outline,
//                           color: Colors.red,
//                         ),
//                       )
//                     ],
//                   )
//                 : GestureDetector(
//                     onTap: () {
//                       // mixpanel?.track(
//                       // 'View Offers Left');
//                       Navigator.pushNamed(context, OfferSelectionScreen.route,
//                           arguments: OfferSelectionScreenArgs(
//                               offerApplyBloc: _offerApplyBloc));
//                     },
//                     child: Text('Select a promo code'))),
//         SizeConfig.kHorizontalMargin8,
//         GestureDetector(
//           onTap: () {
//             // mixpanel?.track(
//             // 'View Offers Right');
//             Navigator.pushNamed(context, OfferSelectionScreen.route,
//                 arguments:
//                     OfferSelectionScreenArgs(offerApplyBloc: _offerApplyBloc));
//           },
//           child: Text('View offers', style: SizeConfig.kStyle14PrimaryColor),
//         )
//       ],
//     );
//   }
// }

//  if (state is CartItemAdded ||
//                   state is CartItemDeleted ||
//                   state is CartLoaded ||
//                   state is CartFunctionLoading) {
//                 if (state is CartItemAdded) {
//                   cart = state.cart;
//                 }
//                 if (state is CartItemDeleted) {
//                   cart = state.cart;
//                 }
//                 if (state is CartLoaded) {
//                   cart = state.cart;
//                 }
//                 if (offerState is OfferApplySuccess) {
//                   cart = offerState.cart;
//                   print('2nd');
//                   print(cart.offer.toString() + "asdasd" + cart.toString());
//                 }
//                 return cart.items!.isEmpty
//                     ? Container(
//                         height: 30.h,
//                         child: Center(
//                             child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               'Empty Cart',
//                               style: SizeConfig.kStyle16W500,
//                             ),
//                             SizeConfig.kHorizontalMargin8,
//                             Icon(
//                               Icons.shopping_cart_outlined,
//                               color: Colors.black,
//                             )
//                           ],
//                         )),
//                       )
//                     : Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: <Widget>[
//                           Padding(
//                             padding: const EdgeInsets.all(20.0),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.location_on_outlined,
//                                   color: SizeConfig.kPrimaryColor,
//                                 ),
//                                 SizedBox(
//                                   width: 8,
//                                 ),
//                                 Expanded(
//                                   child: Text(cart.store!.name!,
//                                       style: SizeConfig.kStyle16W500),
//                                 )
//                               ],
//                             ),
//                           ),
//                           Divider(
//                             height: 1,
//                             thickness: 1,
//                           ),
//                           ...(cart.itemsObj!.map((e) {
//                             return CartItemTile(
//                                 isLoading: state is CartFunctionLoading &&
//                                     state.itemId.contains(e.id),
//                                 cartFunctionBloc: _cartFunctionBloc,
//                                 itemId: e.id,
//                                 price: e.price!.toString(),
//                                 service: e.service!,
//                                 timeInterval: e.timeInterval!.toString());
//                           }).toList()),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 8, horizontal: 16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Text(
//                                   'Offers',
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 SizedBox(
//                                   height: 8,
//                                 ),
//                                 Row(
//                                   children: [
//                                     FaIcon(
//                                       FontAwesomeIcons.moneyBillAlt,
//                                       color: Colors.green,
//                                     ),
//                                     SizedBox(
//                                       width: 8,
//                                     ),
//                                     Expanded(
//                                         child: cart.offer != null
//                                             ? Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   Text(
//                                                     '${cart.offer!.code} (appilied)',
//                                                     style: SizeConfig
//                                                         .kStyle14Bold
//                                                         .copyWith(
//                                                             color: Colors
//                                                                 .deepPurple),
//                                                   ),
//                                                   SizeConfig.kHorizontalMargin4,
//                                                   GestureDetector(
//                                                     onTap: () => _offerApplyBloc
//                                                         .add(RemoveOffer()),
//                                                     child: Icon(
//                                                       Icons
//                                                           .remove_circle_outline,
//                                                       color: Colors.red,
//                                                     ),
//                                                   )
//                                                 ],
//                                               )
//                                             : GestureDetector(
//                                                 onTap: () => Navigator.pushNamed(
//                                                     context,
//                                                     OfferSelectionScreen.route,
//                                                     arguments:
//                                                         OfferSelectionScreenArgs(
//                                                             offerApplyBloc:
//                                                                 _offerApplyBloc)),
//                                                 child: Text(
//                                                     'Select a promo code'))),
//                                     SizeConfig.kHorizontalMargin8,
//                                     GestureDetector(
//                                       onTap: () => Navigator.pushNamed(
//                                           context, OfferSelectionScreen.route,
//                                           arguments: OfferSelectionScreenArgs(
//                                               offerApplyBloc: _offerApplyBloc)),
//                                       child: Text('View offers',
//                                           style:
//                                               SizeConfig.kStyle14PrimaryColor),
//                                     )
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(
//                             height: 24,
//                           ),
//                           cart.offer != null
//                               ? Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 16),
//                                   decoration:
//                                       BoxDecoration(color: Color(0xffF3F8FF)),
//                                   child: Column(
//                                     children: [
//                                       DetailsRowWidget(
//                                           leftText: 'Item total',
//                                           rightText: cart.subTotal!,
//                                           leftStyle: SizeConfig.kStyle14
//                                               .copyWith(
//                                                   color: Color(0xff888888)),
//                                           rightStyle: SizeConfig.kStyle14W500),
//                                       SizeConfig.kverticalMargin8,
//                                       DetailsRowWidget(
//                                           leftWidget: RichText(
//                                               text: TextSpan(children: [
//                                             TextSpan(
//                                                 text: 'Promocode discount ',
//                                                 style: SizeConfig.kStyle14
//                                                     .copyWith(
//                                                         color:
//                                                             Color(0xff888888))),
//                                             TextSpan(
//                                                 text: '(${cart.offer!.code!})',
//                                                 style: SizeConfig.kStyle14
//                                                     .copyWith(
//                                                         color:
//                                                             Color(0xff6326C7)))
//                                           ])),
//                                           rightText:
//                                               '- ${cart.discount!.rupees()}',
//                                           rightStyle: SizeConfig.kStyle14W500
//                                               .copyWith(
//                                                   color: Color(0xff35B549))),
//                                     ],
//                                   ))
//                               : SizedBox.shrink(),
//                           Container(
//                             decoration:
//                                 BoxDecoration(color: Colors.white, boxShadow: [
//                               BoxShadow(
//                                   blurRadius: 4,
//                                   color: Color.fromRGBO(0, 0, 0, .08),
//                                   offset: Offset(0, -2))
//                             ]),
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 8.0, horizontal: 16),
//                             child: SafeArea(
//                               child: Row(
//                                 children: <Widget>[
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: <Widget>[
//                                       Text('₹${cart.total}',
//                                           style: TextStyle(
//                                               fontSize: SizeConfig.kfontSize16,
//                                               fontWeight: FontWeight.w500)),
//                                       SizedBox(
//                                         height: 4,
//                                       ),
//                                       Text(
//                                         'T O T A L',
//                                         style: SizeConfig.kStyle12
//                                             .copyWith(color: Colors.grey[700]),
//                                       ),
//                                     ],
//                                   ),
//                                   Spacer(),
//                                   CommonTextButton(
//                                       onPressed: () {
//                                         _orderReviewBloc
//                                             .add(SetCart(cart: cart));
//                                         Navigator.pop(context);
//                                         Navigator.pushNamed(
//                                             context, SlotSelectScreen.route,
//                                             arguments:
//                                                 SlotSelectScreenArguments(
//                                                     cartTotal: cart.total!,
//                                                     cardId:
//                                                         cart.id!.toString()));
//                                       },
//                                       child: Text('Select Slot',
//                                           style:
//                                               TextStyle(color: Colors.white)),
//                                       backgroundColor: SizeConfig.kPrimaryColor)
//                                   // TextButton(
//                                   //   child: Text('Select Slot',
//                                   //       style: TextStyle(color: Colors.white)),
//                                   //   onPressed: () {
//                                   //     _orderReviewBloc.add(SetCart(cart: cart));
//                                   //     Navigator.pushNamed(
//                                   //         context, SlotSelectScreen.route,
//                                   //         arguments: SlotSelectScreenArguments(
//                                   //             cartTotal: cart.total!,
//                                   //             cardId: cart.id!.toString()));
//                                   //   },
//                                   //   style: ButtonStyle(
//                                   //       backgroundColor: MaterialStateProperty.all(
//                                   //           Theme.of(context).primaryColor)),
//                                   // ),
//                                 ],
//                               ),
//                             ),
//                           )
//                         ],
//                       );
//               }

// return Container(
//   child: Center(
//     child: loadingAnimation(),
//   ),
//   height: 300,
// );
