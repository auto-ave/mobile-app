import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:logger/logger.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:themotorwash/blocs/offer_apply/bloc/offer_apply_bloc.dart';

import 'package:themotorwash/blocs/offer_list/bloc/offer_list_bloc.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/utils/utils.dart';

class OfferSelectionScreen extends StatefulWidget {
  static const String route = '/offerSelection';
  const OfferSelectionScreen({Key? key, required this.offerApplyBloc})
      : super(key: key);
  final OfferApplyBloc offerApplyBloc;

  @override
  _OfferSelectionScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    return _OfferSelectionScreenState();
  }
}

class _OfferSelectionScreenState extends State<OfferSelectionScreen> {
  late final OfferListBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  final offerTextController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc =
        OfferListBloc(repository: RepositoryProvider.of<Repository>(context));
    _bloc.add(GetOffersList());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarWithBackButton(
          context: context,
          title: Text(
            'Select promo code',
            style: SizeConfig.kStyle20W500,
          )),
      body: BlocListener<OfferApplyBloc, OfferApplyState>(
        bloc: widget.offerApplyBloc,
        listener: (context, state) {
          // TODO: implement listener
          if (state is OfferApplyError &&
              state.offerErrorType == OfferError.apply) {
            showSnackbar(context, 'Offer code not valid');
          }
          // else if (state is OfferApplySuccess) {
          //   showSnackbar(context, 'Offer Applied');
          // }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        validator: (string) {
                          if (string != null && string.isNotEmpty) {
                            return null;
                          }
                          return 'Enter a valid code';
                        },
                        controller: offerTextController,
                        decoration: InputDecoration(
                          hintText: 'Enter promo code',
                          border: InputBorder.none,
                          suffixIcon: FittedBox(
                            // color: Colors.amber,

                            child: RoundedLoadingButton(
                              elevation: 0,
                              child: Text(
                                'Apply',
                                style: SizeConfig.kStyle16W500
                                    .copyWith(color: SizeConfig.kPrimaryColor),
                              ),
                              controller: RoundedLoadingButtonController(),
                              borderRadius: 4,
                              width: 60,
                              height: 40,
                              color: Colors.white,
                              animateOnTap: false,
                              onPressed: () async {
                                if (_formKey.currentState != null) {
                                  if (_formKey.currentState!.validate()) {
                                    widget.offerApplyBloc.add(ApplyOffer(
                                        code: offerTextController.text));
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    SizeConfig.kverticalMargin32,
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(color: Color(0xffF5F5F5)),
                child: Text(
                  'Available offers',
                  style: SizeConfig.kStyle16W500,
                ),
              ),
            ),
            BlocBuilder<OfferListBloc, OfferListState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is OfferListLoaded) {
                  var offers = state.offers;
                  if (offers.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text('No offers available'),
                      ),
                    );
                  }
                  return SliverList(
                      delegate: SliverChildBuilderDelegate((ctx, index) {
                    var offer = offers[index];
                    return OfferTile(
                        saving: offer.saving ?? '',
                        offerApplyBloc: widget.offerApplyBloc,
                        onApply: () {
                          widget.offerApplyBloc
                              .add(ApplyOffer(code: offer.code!));
                        },
                        title: offer.title!,
                        description: offer.description!,
                        code: offer.code!);
                  }, childCount: offers.length));
                }
                return SliverFillRemaining(
                  child: loadingAnimation(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class OfferTile extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final String saving;
  final VoidCallback onApply;
  final OfferApplyBloc offerApplyBloc;
  OfferTile(
      {Key? key,
      required this.title,
      required this.description,
      required this.code,
      required this.onApply,
      required this.offerApplyBloc,
      required this.saving})
      : super(key: key);
  final RoundedLoadingButtonController _controller =
      RoundedLoadingButtonController();
  @override
  Widget build(BuildContext context) {
    return BlocListener<OfferApplyBloc, OfferApplyState>(
      bloc: offerApplyBloc,
      listener: (context, state) {
        // TODO: implement listener
        Logger().d(
            "gelll" + _controller.currentState.toString() + state.toString());
        if (state is OfferApplyError &&
            _controller.currentState == ButtonState.loading) {
          _controller.stop();
        } else if (state is OfferApplySuccess &&
            _controller.currentState == ButtonState.loading) {
          _controller.stop();
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8.0),
        color: Color(0xffF5F5F5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: SizeConfig.kStyle16,
              ),
              SizeConfig.kverticalMargin4,
              Text(
                description,
                style: SizeConfig.kStyle14
                    .copyWith(color: SizeConfig.kGreyTextColor),
              ),
              SizeConfig.kverticalMargin16,
              Row(
                children: [
                  DashedOfferCodeBadge(offerCode: code),
                  Spacer(),
                  FittedBox(
                    child: RoundedLoadingButton(
                      onPressed: () {
                        onApply();
                      },
                      valueColor: SizeConfig.kPrimaryColor,
                      child: Text(
                        'Apply',
                        style: SizeConfig.kStyle16W500
                            .copyWith(color: SizeConfig.kPrimaryColor),
                      ),
                      color: Colors.white,
                      borderRadius: 4,
                      width: 60,
                      height: 40,
                      elevation: 0,
                      controller: _controller,
                    ),
                  ),
                ],
              ),
              Divider(),
              Text(
                saving,
                style: SizeConfig.kStyle12W500
                    .copyWith(color: SizeConfig.kPrimaryColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DashedOfferCodeBadge extends StatelessWidget {
  final String offerCode;
  const DashedOfferCodeBadge({Key? key, required this.offerCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
        color: SizeConfig.kPrimaryColor,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(color: Color(0xffF3F8FF)),
          child: Text(
            offerCode,
            style: SizeConfig.kStyle12
                .copyWith(fontWeight: FontWeight.bold, letterSpacing: 3),
          ),
        ));
  }
}
