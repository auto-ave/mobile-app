import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:themotorwash/blocs/cart/cart_function_bloc.dart';
import 'package:themotorwash/data/models/store.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/store_detail/blocs/store_detail_bloc.dart';
import 'package:themotorwash/ui/screens/store_detail/components/pages/overview/store_overview_tab.dart';
import 'package:themotorwash/ui/screens/store_detail/components/pages/reviews/store_reviews_tab.dart';
import 'package:themotorwash/ui/screens/store_detail/components/pages/services/store_services_tab.dart';
import 'package:themotorwash/ui/widgets/bottom_cart_tile.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/shimmer_placeholder.dart';
import 'package:themotorwash/utils.dart';

class StoreDetailScreen extends StatefulWidget {
  final String storeSlug;
  StoreDetailScreen({Key? key, required this.storeSlug}) : super(key: key);
  static final String route = "/storeDetails";

  @override
  _StoreDetailScreenState createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  late StoreDetailBloc _storeDetailBloc;
  late CartFunctionBloc _cartFunctionBloc;
  final _scaffoldState = GlobalKey<ScaffoldState>();
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _storeDetailBloc = BlocProvider.of<StoreDetailBloc>(context);
    _cartFunctionBloc = BlocProvider.of<CartFunctionBloc>(context);
    _cartFunctionBloc.add(GetCart());
    _storeDetailBloc.add(LoadStoreDetail(storeSlug: widget.storeSlug));
  }

  String? storeName;

  late PersistentBottomSheetController bottomSheetController;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final height = mediaQuery.height;
    final width = mediaQuery.width;

    return Scaffold(
      appBar: storeName != null
          ? getAppBarWithBackButton(
              context: context,
              title: Text(
                storeName!,
                style: kStyle14SemiBold.copyWith(color: Colors.black),
              ))
          : null,
      key: _scaffoldState,
      bottomNavigationBar: BlocBuilder<StoreDetailBloc, StoreDetailState>(
        builder: (context, detailState) {
          return BlocBuilder<CartFunctionBloc, CartFunctionState>(
            builder: (context, state) {
              if (detailState is StoreDetailLoaded) {
                if (state is CartLoading) {
                  return Container(
                    width: 0,
                    height: 0,
                  );
                }
                if (state is CartFunctionUninitialized) {
                  return Container(
                    width: 0,
                    height: 0,
                  );
                }
                if (state is CartItemAdded) {
                  return state.cart.items!.isNotEmpty &&
                          detailState.store.id == state.cart.store!.id
                      ? BottomCartTile(cart: state.cart)
                      : Container(
                          width: 0,
                          height: 0,
                        );
                }

                if (state is CartItemDeleted) {
                  return state.cart.items!.isNotEmpty &&
                          detailState.store.id == state.cart.store!.id
                      ? BottomCartTile(cart: state.cart)
                      : Container(
                          width: 0,
                          height: 0,
                        );
                }
                if (state is CartLoaded) {
                  return state.cart.items!.isNotEmpty &&
                          detailState.store.id == state.cart.store!.id
                      ? BottomCartTile(cart: state.cart)
                      : Container(
                          width: 0,
                          height: 0,
                        );
                }
              }
              return Container(
                width: 0,
                height: 0,
              );
            },
          );
        },
      ),
      body: BlocConsumer<StoreDetailBloc, StoreDetailState>(
        bloc: _storeDetailBloc,
        listener: (_, state) {
          if (state is StoreDetailLoaded) {
            setState(() {
              storeName = state.store.name;
            });
          }
        },
        builder: (context, state) {
          if (state is StoreDetailLoading) {
            Center(
              child: loadingAnimation(),
            );
          }
          if (state is StoreDetailLoaded) {
            Store store = state.store;
            return DefaultTabController(
              initialIndex: _selectedTab,
              length: 3,
              child: NestedScrollView(headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                // These are the slivers that show up in the "outer" scroll view.
                return <Widget>[
                  SliverToBoxAdapter(
                    child: CarouselSlider(
                      options: CarouselOptions(viewportFraction: 1),
                      items: store.images!.map<Widget>((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return CachedNetworkImage(
                              placeholder: (_, __) {
                                return ShimmerPlaceholder();
                              },
                              imageUrl: i,
                              width: width,
                              height: width * 3 / 5,
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            controller: _tabController,
                            onTap: (index) {
                              setState(() {
                                _selectedTab = index;
                              });
                            },
                            labelStyle: selectedTabTextStyle,
                            unselectedLabelColor: Colors.black,
                            labelColor: kPrimaryColor,
                            unselectedLabelStyle: unSelectedTabTextStyle,
                            tabs: [
                              new Tab(
                                text: 'Overview',
                              ),
                              new Tab(
                                text: 'Services',
                              ),
                              new Tab(
                                text: 'Reviews',
                              ),
                            ],
                          ),
                        )),
                  ),
                ];
              }, body: Builder(builder: (context) {
                return TabBarView(
                  // physics: NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: getSelectedTabPage(context, store),
                );
                // return Padding(
                //   padding: const EdgeInsets.only(top: 16),
                //   child: getSelectedTabPage(context, _selectedTab, state.store),
                // );
              })),
            );
          }
          if (state is StoreDetailError) {
            return Center(
              child: ErrorScreen(
                ctaType: ErrorCTA.reload,
                onCTAPressed: () {
                  _cartFunctionBloc.add(GetCart());
                  _storeDetailBloc
                      .add(LoadStoreDetail(storeSlug: widget.storeSlug));
                },
              ),
            );
          }
          return Center(
            child: loadingAnimation(),
          );
        },
      ),
    );
  }

  List<Widget> getSelectedTabPage(
      BuildContext nestedScrollContext, Store store) {
    List<Widget> tabPages = [
      StoreOverviewTab(
        onPressedBook: () {
          setState(() {
            _selectedTab = 1;
            _tabController.animateTo(1);
          });
        },
        onPressedRating: () {
          setState(() {
            _selectedTab = 2;
            _tabController.animateTo(2);
          });
        },
        nestedScrollContext: nestedScrollContext,
        storeSlug: widget.storeSlug,
        store: store,
      ),
      StoreServicesTab(
        nestedScrollContext: nestedScrollContext,
        storeSlug: widget.storeSlug,
        scaffoldState: _scaffoldState,
      ),
      StoreReviewsTab(
        nestedScrollContext: nestedScrollContext,
        storeSlug: widget.storeSlug,
      ),
    ];
    return tabPages;
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      // ADD THE COLOR YOU WANT AS BACKGROUND.
      child: _tabBar,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          offset: Offset(0, 4),
          blurRadius: 12,
          color: Color.fromRGBO(0, 0, 0, .16),
        )
      ]),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
