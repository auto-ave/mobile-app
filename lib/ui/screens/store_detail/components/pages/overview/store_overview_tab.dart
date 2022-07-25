import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:map_launcher/map_launcher.dart';

import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/store_detail/components/pages/overview/components/store_google_map.dart';
import 'package:themotorwash/ui/screens/store_detail/components/pages/overview/components/store_hamper_offer/store_hamper_offer_widget.dart';
import 'package:themotorwash/ui/screens/store_detail/components/pages/overview/components/store_heading.dart';
import 'package:themotorwash/ui/screens/store_detail/components/pages/overview/components/store_info.dart';
import 'package:themotorwash/ui/widgets/directions_button.dart';

class StoreOverviewTab extends StatefulWidget {
  final BuildContext nestedScrollContext;
  final String storeSlug;
  final Store store;
  final VoidCallback onPressedBook;
  final VoidCallback onPressedRating;
  const StoreOverviewTab({
    Key? key,
    required this.nestedScrollContext,
    required this.storeSlug,
    required this.store,
    required this.onPressedBook,
    required this.onPressedRating,
  }) : super(key: key);

  @override
  _StoreOverviewTabState createState() {
    FlutterUxcam.tagScreenName('StoreOverviewTab');
    return _StoreOverviewTabState();
  }
}

class _StoreOverviewTabState extends State<StoreOverviewTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).viewInsets.bottom.toString() + "hasdhhasdh");
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: BookServiceButton(
          onPressed: widget.onPressedBook,
        ),
      ),
      body: CustomScrollView(
        key: PageStorageKey<String>('StoreOverviewTab'),
        slivers: [
          SliverOverlapInjector(
            // This is the flip side of the SliverOverlapAbsorber
            // above.
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                widget.nestedScrollContext),
          ),
          SliverPadding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
            sliver: SliverToBoxAdapter(
                child: StoreHeading(
              onPressedRating: widget.onPressedRating,
              name: widget.store.name!,
              numberOfRatings: widget.store.ratingCount!,
              rating: widget.store.rating,
            )),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverToBoxAdapter(
                child: StoreInfo(
              address: widget.store.address!,
              displayDaysOpen: widget.store.displayDaysOpen,
              displayOpenClosingTime: widget.store.displayOpeningClosingTime,
              // closingTime: store.storeClosingTime!,
              // openingTime: store.storeOpeningTime!,
              serviceStartsAt:
                  widget.store.servicesStart.toString(), //TODO : todo
            )),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: StoreHamperOfferWidget(),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            sliver: SliverToBoxAdapter(
                child: Text(
              'About',
              style: SizeConfig.kStyle20W500,
            )),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            sliver: SliverToBoxAdapter(
                child: Text(
              widget.store.description!,
              style: SizeConfig.kStyle12,
            )),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            sliver: SliverToBoxAdapter(
                child: StoreGoogleMap(
              storeTitle: widget.store.name!,
              latitute: widget.store.latitude!,
              longitute: widget.store.longitude!,
            )
                //      StoreMap(
                // latitute: widget.store.latitude!,
                // longitute: widget.store.longitude!,
                // )
                ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            sliver: SliverToBoxAdapter(
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: DirectionsButton(
                      latitude: widget.store.latitude!,
                      longitude: widget.store.longitude!)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class BookServiceButton extends StatelessWidget {
  const BookServiceButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
        // mixpanel?.track('Book Service Button');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 4),
                  color: Color.fromRGBO(17, 17, 17, .32),
                  blurRadius: 32)
            ],
            // gradient: LinearGradient(
            //   // begin: Alignment(0.0, 0.0),
            //   // end: Alignment(0.997, 0.082),
            //   begin: Alignment(0.0, 0.0),
            //   end: Alignment(0.999, 0.046),
            //   // transform: GradientRotation(1.5708),
            //   colors: [
            //     Theme.of(context).primaryColor,
            //     Color(0xff98CFF8),
            //   ],
            // ),
            color: SizeConfig.kPrimaryColor,
            borderRadius: BorderRadius.circular(8)),
        child: Text(
          'BOOK SERVICE',
          style: SizeConfig.kStyle14Bold
              .copyWith(color: Colors.white, letterSpacing: 5),
        ),
      ),
    );
  }
}
