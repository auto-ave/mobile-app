import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:logger/logger.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:themotorwash/blocs/cart/cart_function_bloc.dart';
import 'package:themotorwash/blocs/featured_stores/bloc/featured_stores_bloc.dart';
import 'package:themotorwash/blocs/global_auth/global_auth_bloc.dart';
import 'package:themotorwash/blocs/global_location/global_location_bloc.dart';
import 'package:themotorwash/blocs/location_functions/bloc/location_functions_bloc.dart';
import 'package:themotorwash/blocs/offer_banners/offer_banners_bloc.dart';
import 'package:themotorwash/blocs/search_services/search_services_bloc.dart';
import 'package:themotorwash/blocs/search_stores/search_stores_bloc.dart';
import 'package:themotorwash/data/analytics/analytics_events.dart';
import 'package:themotorwash/data/models/location_model.dart';
import 'package:themotorwash/data/models/store_list_model.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_hamper/explore_hamper_widget.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_offers/explore_offers_carousel.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_picks/explore_picks_widget.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/explore_services_grid.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/explore_services_tile.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_stores/explore_stores_list.dart';
import 'package:themotorwash/ui/screens/explore/components/grant_location_permission_screen.dart';
import 'package:themotorwash/ui/screens/explore/components/initial_search_screen/initial_search_screen.dart';
import 'package:themotorwash/ui/screens/explore/components/search_overlay.dart';
import 'package:themotorwash/ui/screens/explore/components/search_service_tile.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_stores/store_tile.dart';
import 'package:themotorwash/ui/screens/login/login_screen.dart';
import 'package:themotorwash/ui/screens/store_detail/components/cart_bottom_sheet.dart';
import 'package:themotorwash/ui/screens/store_detail/store_detail_screen.dart';
import 'package:themotorwash/ui/screens/store_list/bloc/store_list_bloc.dart';
import 'package:themotorwash/ui/widgets/bottom_cart_tile.dart';
import 'package:themotorwash/ui/widgets/drawer.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/ui/widgets/loading_more_tile.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/loading_widgets/explore_services_loading.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_stores/loading_widgets/explore_stores_loading_list.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/scrollable_service_loading.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/service_search_loading_tile.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_stores/loading_widgets/store_loading_tile.dart';
import 'package:themotorwash/ui/widgets/search_bar.dart';
import 'package:themotorwash/utils/utils.dart';

class ExploreScreen extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;

  const ExploreScreen({Key? key, required this.initialLink}) : super(key: key);
  static final String route = '/exploreScreen';

  @override
  _ExploreScreenState createState() {
    FlutterUxcam.tagScreenName(route);
    return _ExploreScreenState();
  }
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  FocusNode _node = FocusNode();
  bool _showSearch = false;
  late StoreListBloc _storeListBloc;
  late GlobalLocationBloc _globalLocationBloc;
  late SearchServicesBloc _searchServicesBloc;
  late SearchServicesBloc _privateSearchServicesBloc;
  late SearchStoresBloc _searchStoresBloc;
  final TextEditingController textController = TextEditingController();
  String currentText = "";
  List<StoreListModel> stores = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late CartFunctionBloc _cartFunctionBloc;
  late GlobalAuthBloc _globalAuthBloc;
  late final OfferBannersBloc _bannersBloc;
  late final FeaturedStoresBloc _featuredStoresBloc;
  // late final AnimationController _animationController;
  // late final Animation _appBarAnimation;
  double begin = 0;
  double end = 56;
  @override
  void initState() {
    super.initState();

    Repository repository = RepositoryProvider.of<Repository>(context);
    _globalLocationBloc = BlocProvider.of<GlobalLocationBloc>(context);
    _storeListBloc = StoreListBloc(
        repository: repository, globalLocationBloc: _globalLocationBloc);
    _globalAuthBloc = BlocProvider.of<GlobalAuthBloc>(context);
    _globalLocationBloc.add(GetCurrentUserLocation());
    _searchServicesBloc = SearchServicesBloc(repository: repository);
    _privateSearchServicesBloc = SearchServicesBloc(repository: repository);
    _privateSearchServicesBloc.add(
        SearchServices(query: '', forLoadMore: false, offset: 0, pageLimit: 6));
    _searchStoresBloc = SearchStoresBloc(
        repository: repository, globalLocationBloc: _globalLocationBloc);
    _featuredStoresBloc = FeaturedStoresBloc(
        repository: repository, globalLocationBloc: _globalLocationBloc);
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 300),
    // );
    // _appBarAnimation =
    //    .animate(_animationController);
    _node.addListener(() {
      // _node.hasFocus
      //     ? _animationController.forward()
      //     : _animationController.reverse();
      if (mounted) {
        setState(() {
          begin = !_node.hasFocus ? 0 : 56;
          end = !_node.hasFocus ? 56 : 0;
          _node.hasFocus ? _showSearch = true : _showSearch = false;
        });
      }
    });
    // _appBarAnimation.addListener(() {
    //   setState(() {});
    // });
    // _animationController.forward();
    _cartFunctionBloc = BlocProvider.of<CartFunctionBloc>(context);
    _bannersBloc = OfferBannersBloc(
        repository: RepositoryProvider.of<Repository>(context));
    if (_globalAuthBloc.state is Authenticated) {
      print('if called');
      _cartFunctionBloc.add(GetCart());
    }
    if (widget.initialLink != null) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        if (widget.initialLink?.link?.queryParameters['store'] != null) {
          final slug =
              widget.initialLink?.link?.queryParameters['store'] as String;
          autoaveLog('slug $slug');
          Navigator.pushNamed(context, StoreDetailScreen.route,
              arguments: StoreDetailArguments(storeSlug: slug));
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _storeListBloc.close();
    _searchServicesBloc.close();
    _privateSearchServicesBloc.close();
    _searchStoresBloc.close();
    _featuredStoresBloc.close();
    _bannersBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    // print(_appBarAnimation.value.toString() + " value ");
    // Future.delayed(Duration(seconds: 1)).then((value) =>
    //     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light));
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    print("helofrom" + MediaQuery.of(context).padding.top.toString());
    return WillPopScope(
      onWillPop: () async {
        if (_node.hasFocus) {
          _node.unfocus();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: BlocListener<GlobalAuthBloc, GlobalAuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                  context, LoginScreen.route, (route) => false);
            }
          },
          child: BlocConsumer<GlobalLocationBloc, GlobalLocationState>(
              bloc: _globalLocationBloc,
              listener: (context, state) {
                if (state is LocationSet) {
                  print('Location Set');
                  _storeListBloc
                      .add(LoadNearbyStoreList(offset: 0, forLoadMore: false));
                  _featuredStoresBloc.add(LoadFeaturedStores());
                }
                if (state is GlobalLocationError) {
                  showSnackbar(context,
                      'Failed to set location. Please try againg later');
                }
              },
              builder: (_, state) {
                if (state is LocationSet) {
                  return _buildScreen(state);
                }
                // if (state is RetrievingLocation) {
                //   return GrantLocationPermissionScreen(
                //     globalLocationBloc: _globalLocationBloc,
                //     forPermission: true,
                //     isLoading: true,
                //   );
                // }
                if (state is LocationPermissionError) {
                  autoaveLog('LocationPermissionError');

                  return GrantLocationPermissionScreen(
                    globalLocationBloc: _globalLocationBloc,
                    forPermission: true,
                  );
                }
                if (state is LocationServiceNotEnabledError) {
                  autoaveLog('LocationServiceNotEnabledError');
                  return GrantLocationPermissionScreen(
                    globalLocationBloc: _globalLocationBloc,
                    forPermission: false,
                  );
                }
                if (state is GlobalLocationError) {
                  autoaveLog('GlobalLocationError');
                  return GrantLocationPermissionScreen(
                    globalLocationBloc: _globalLocationBloc,
                    forPermission: true,
                  );
                }
                print('state is $state');
                return Center(
                  // child: Text('herllasdlas'),
                  child: loadingAnimation(),
                );
              }),
        ),
      ),
    );
  }

  _buildScreen(LocationSet locationState) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 200),
      tween: Tween<double>(begin: begin, end: end),
      builder: (context, double value, child) {
        return BlocListener<GlobalAuthBloc, GlobalAuthState>(
          listener: (context, state) {
            // TODO: implement listenerprint('Satate' + state.toString());
            if (state is Unauthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                  context, LoginScreen.route, (route) => false);
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(locationState.location, value),
            endDrawer:
                //  AnnotatedRegion<SystemUiOverlayStyle>(
                //     value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
                //     child:
                AppDrawer(),
            // ),
            body: child,
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20,
              bottom: 20,
              top: 16,
            ),
            child: SearchBar(
              textController: textController,
              onChanged: (value) {
                if (value.trim() != '' && currentText != value) {
                  _searchServicesBloc.add(SearchServices(
                      query: value, forLoadMore: false, offset: 0));
                  _searchStoresBloc.add(SearchStores(
                      query: value, forLoadMore: false, offset: 0));
                }
                if (value.trim() == '') {
                  _searchServicesBloc.add(YieldUninitializedState());
                }
                currentText = value;
              },
              focusNode: _node,
              hintText: 'Search services, stores...',
            ),
          ),
          Expanded(
              child: _showSearch
                  ? BlocBuilder<SearchServicesBloc, SearchServicesState>(
                      bloc: _searchServicesBloc,
                      builder: (context, state) {
                        if (state is SearchServicesUninitialized) {
                          return InitialSearchScreen();
                        }
                        return SearchOverlay(
                          textController: textController,
                          searchServicesBloc: _searchServicesBloc,
                          searchStoresBloc: _searchStoresBloc,
                        );
                      },
                    )
                  : BlocBuilder<StoreListBloc, StoreListState>(
                      bloc: _storeListBloc,
                      builder: (context, storeState) {
                        return BlocBuilder<SearchServicesBloc,
                            SearchServicesState>(
                          bloc: _privateSearchServicesBloc,
                          builder: (context, servicesState) {
                            if (storeState is StoreListError ||
                                servicesState is SearchedServicesError) {
                              return Center(
                                child: ErrorScreen(
                                  ctaType: ErrorCTA.reload,
                                  onCTAPressed: _onRefresh,
                                ),
                              );
                              ;
                            }
                            return _buidExploreSection();
                          },
                        );
                      },
                    ))
        ],
      ),
    );
  }

  void _onRefresh() async {
    if (_globalLocationBloc.state is LocationSet) {
      _storeListBloc.add(LoadNearbyStoreList(offset: 0, forLoadMore: false));
      _privateSearchServicesBloc.add(SearchServices(
          query: '', forLoadMore: false, offset: 0, pageLimit: 6));
      _bannersBloc.add(GetOffersBanners());
      _featuredStoresBloc.add(LoadFeaturedStores());
      HapticFeedback.mediumImpact();
    }
  }

  Widget _buidExploreSection() {
    return LazyLoadScrollView(
        onEndOfPage: _loadMoreStores,
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: ClassicHeader(
            completeText: '',
            completeIcon: null,
            refreshingText: '',
            releaseText: '',
            idleText: '',
            completeDuration: Duration(milliseconds: 0),
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: CustomScrollView(slivers: [
            ExploreHamperWidget(),
            SliverToBoxAdapter(
              child: SizeConfig.kverticalMargin16,
            ),
            ExploreOffersCarousel(
              bannersBloc: _bannersBloc,
            ),
            SliverToBoxAdapter(
              child: SizeConfig.kverticalMargin16,
            ),

            BlocBuilder<SearchServicesBloc, SearchServicesState>(
              bloc: _privateSearchServicesBloc,
              builder: (context, state) {
                if (state is LoadingSearchServicesResult) {
                  return ExploreServicesGridLoading();
                }
                if (state is SearchedServicesResult) {
                  autoaveLog(state.searchedServices.toString());
                  return state.searchedServices.isNotEmpty
                      ? ExploreServicesGrid(
                          items: state.searchedServices
                              .map((e) => ExploreServiceTile(
                                    imageUrl: e.thumbnail!,
                                    serviceName: e.name!,
                                    serviceTag: e.slug!,
                                    bannerUrl:
                                        e.bannerUrl ?? SizeConfig.autoaveBanner,
                                  ))
                              .toList(),
                        )
                      : SliverToBoxAdapter(child: Container());
                }
                if (state is SearchedServicesError) {
                  return SliverToBoxAdapter(
                    child: Container(),
                  );
                }

                return ExploreServicesGridLoading();
              },
            ),
            ExplorePicksWidget(
              featuredStoresBloc: _featuredStoresBloc,
            ),
            // SliverPadding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   sliver: SliverToBoxAdapter(
            //       child: Text(
            //     'Carwashes near you',
            //     style: SizeConfig.kStyle16W500,
            //   )),
            // ),
            BlocConsumer<StoreListBloc, StoreListState>(
                listener: (_, state) {
                  if (state is StoreListLoaded) {
                    //TODO Find alternative for this workaround (Need setState for lazyloading to trigger)
                    _refreshController.refreshCompleted();
                    setState(() {});
                  }
                },
                bloc: _storeListBloc,
                builder: (context, state) {
                  if (state is StoreListLoaded ||
                      state is MoreStoreListLoading) {
                    if (state is StoreListLoaded) {
                      stores = state.stores;
                    }
                    return ExploreStoresList(state: state, stores: stores);
                    // return SliverList(
                    //     delegate: SliverChildBuilderDelegate(
                    //   (_, index) {
                    //     var store = stores[index];
                    //     var tile = StoreTile(
                    //       address: store.address!,
                    //       distance: store.distance!,
                    //       imageURL: store.thumbnail!,
                    //       rating: store.rating,
                    //       storeName: store.name,
                    //       startingFrom: store.servicesStart!,
                    //       storeSlug: store.storeSlug!,
                    //     );
                    //     if (state is MoreStoreListLoading &&
                    //         index == stores.length - 1) {
                    //       return LoadingMoreTile(tile: tile);
                    //     }
                    //     return tile;
                    //   },
                    //   childCount: stores.length,
                    // ));
                  }
                  if (state is StoreListError) {
                    return SliverFillRemaining(
                      child: ErrorScreen(
                        ctaType: ErrorCTA.reload,
                        onCTAPressed: _onRefresh,
                      ),
                    );
                  }
                  return ExploreStoresLoadingList();
                })
          ]),
        ));
  }

  void _loadMoreStores() {
    StoreListState currentState = _storeListBloc.state;
    if (!_storeListBloc.hasReachedMax(currentState, true)) {
      if (currentState is StoreListLoaded) {
        _storeListBloc
            .add(LoadNearbyStoreList(offset: stores.length, forLoadMore: true));
      }
    }
  }

  PreferredSizeWidget _buildAppBar(LocationModel locationModel, double height) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark),
        elevation: 0,
        actionsIconTheme: IconThemeData(color: SizeConfig.kPrimaryColor),
        backgroundColor: Colors.transparent,
        title: Center(
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showSnackbar(context,
                      'We currently only serve in ${locationModel.cityName}');
                  //
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: SizeConfig.kPrimaryColor,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      locationModel.cityName,
                      style: SizeConfig.kStyle16PrimaryColor,
                    ),
                  ],
                ),
              ),
              Spacer(),
              BlocConsumer<GlobalAuthBloc, GlobalAuthState>(
                listener: (_, state) {
                  if (state is Authenticated) {
                    print('listener called');
                    _cartFunctionBloc.add(GetCart());
                  }
                },
                bloc: _globalAuthBloc,
                builder: (context, state) {
                  if (state is Authenticated) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _showCartSheet(context: context),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/cart.svg',
                            width: 24,
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: BlocBuilder<CartFunctionBloc,
                                CartFunctionState>(
                              bloc: _cartFunctionBloc,
                              builder: (context, state) {
                                int? count;

                                if (state is CartItemAdded) {
                                  count = state.cart.items!.length;
                                }

                                if (state is CartItemDeleted) {
                                  count = state.cart.items!.length;
                                }
                                if (state is CartLoaded) {
                                  count = state.cart.items!.length;
                                }

                                if (count != null && count != 0) {
                                  return Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle),
                                      child: Text(
                                        count.toString(),
                                        style: SizeConfig.kStyle10
                                            .copyWith(color: Colors.white),
                                      ));
                                }
                                return Container();
                              },
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _showCartSheet({required BuildContext context}) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8))),
        builder: (_) {
          return CartBottomSheet();
        });
  }
}
