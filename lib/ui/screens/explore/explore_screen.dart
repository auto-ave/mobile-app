import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:themotorwash/blocs/cart/cart_function_bloc.dart';
import 'package:themotorwash/blocs/global_auth/global_auth_bloc.dart';
import 'package:themotorwash/blocs/global_location/global_location_bloc.dart';
import 'package:themotorwash/blocs/location_functions/bloc/location_functions_bloc.dart';
import 'package:themotorwash/blocs/search_services/search_services_bloc.dart';
import 'package:themotorwash/blocs/search_stores/search_stores_bloc.dart';
import 'package:themotorwash/data/models/location_model.dart';
import 'package:themotorwash/data/models/store_list_model.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/navigation/arguments.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/explore/components/grant_location_permission_screen.dart';
import 'package:themotorwash/ui/screens/explore/components/search_overlay.dart';
import 'package:themotorwash/ui/screens/explore/components/search_service_tile.dart';
import 'package:themotorwash/ui/screens/explore/components/store_tile.dart';
import 'package:themotorwash/ui/screens/store_detail/components/cart_bottom_sheet.dart';
import 'package:themotorwash/ui/screens/store_detail/store_detail_screen.dart';
import 'package:themotorwash/ui/screens/store_list/bloc/store_list_bloc.dart';
import 'package:themotorwash/ui/widgets/bottom_cart_tile.dart';
import 'package:themotorwash/ui/widgets/drawer.dart';
import 'package:themotorwash/ui/widgets/loading_more_tile.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/scrollable_service_loading.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/service_search_loading_tile.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/store_loading_tile.dart';
import 'package:themotorwash/ui/widgets/search_bar.dart';
import 'package:themotorwash/utils.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);
  static final String route = '/exploreScreen';

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
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
    _privateSearchServicesBloc
        .add(SearchServices(query: '', forLoadMore: false, offset: 0));
    _searchStoresBloc = SearchStoresBloc(
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

      setState(() {
        begin = !_node.hasFocus ? 0 : 56;
        end = !_node.hasFocus ? 56 : 0;
        _node.hasFocus ? _showSearch = true : _showSearch = false;
      });
    });
    // _appBarAnimation.addListener(() {
    //   setState(() {});
    // });
    // _animationController.forward();
    _cartFunctionBloc = BlocProvider.of<CartFunctionBloc>(context);
    if (_globalAuthBloc.state is Authenticated) {
      print('if called');
      _cartFunctionBloc.add(GetCart());
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(_appBarAnimation.value.toString() + " value ");
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
        body: BlocConsumer<GlobalLocationBloc, GlobalLocationState>(
            bloc: _globalLocationBloc,
            listener: (context, state) {
              if (state is LocationSet) {
                _storeListBloc
                    .add(LoadNearbyStoreList(offset: 0, forLoadMore: false));
              }
              if (state is GlobalLocationError) {
                showSnackbar(
                    context, 'Failed to set location. Please try againg later');
              }
            },
            builder: (_, state) {
              if (state is LocationSet) {
                return _buildScreen(state);
              }
              if (state is LocationPermissionError) {
                return GrantLocationPermissionScreen(
                  globalLocationBloc: _globalLocationBloc,
                  forPermission: true,
                );
              }
              if (state is LocationServiceNotEnabledError) {
                return GrantLocationPermissionScreen(
                  globalLocationBloc: _globalLocationBloc,
                  forPermission: false,
                );
              }
              if (state is GlobalLocationError) {
                return GrantLocationPermissionScreen(
                  globalLocationBloc: _globalLocationBloc,
                  forPermission: true,
                );
              }
              return Center(
                child: loadingAnimation(),
              );
            }),
      ),
    );
  }

  _buildScreen(LocationSet locationState) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 200),
      tween: Tween<double>(begin: begin, end: end),
      builder: (context, double value, child) {
        return Scaffold(
          appBar: _buildAppBar(locationState.location, value),
          endDrawer: AppDrawer(),
          body: child,
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
                          return Center(
                            child: SvgPicture.asset(
                                'assets/images/search_placeholder.svg'),
                          );
                        }
                        return SearchOverlay(
                          textController: textController,
                          searchServicesBloc: _searchServicesBloc,
                          searchStoresBloc: _searchStoresBloc,
                        );
                      },
                    )
                  : _buidExploreSection())
        ],
      ),
    );
  }

  void _onRefresh() async {
    if (_globalLocationBloc.state is LocationSet) {
      _storeListBloc.add(LoadNearbyStoreList(offset: 0, forLoadMore: false));
      _privateSearchServicesBloc
          .add(SearchServices(query: '', forLoadMore: false, offset: 0));
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
          // onLoading: _onLoading,
          child: CustomScrollView(slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Services',
                  style: kStyle20W500,
                ),
              ),
            ),
            BlocBuilder<SearchServicesBloc, SearchServicesState>(
              bloc: _privateSearchServicesBloc,
              builder: (context, state) {
                if (state is LoadingSearchServicesResult) {
                  return SliverToBoxAdapter(child: ScrollableServiceLoading());
                }
                if (state is SearchedServicesResult) {
                  return SliverToBoxAdapter(
                    child: state.searchedServices.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize
                                    .min, //TODO : 12 +4 padding check
                                children: <Widget>[
                                      kHorizontalMargin8,
                                      kHorizontalMargin4
                                    ] +
                                    state.searchedServices
                                        .map((e) => SearchServiceTile(
                                              imageUrl: e.thumbnail!,
                                              serviceName: e.name!,
                                            ))
                                        .toList(),
                              ),
                            ),
                          )
                        : Container(
                            child:
                                Center(child: Text('No services to display')),
                            width: double.infinity,
                            height: 100,
                          ),
                  );
                }
                if (state is SearchedServicesError) {}
                return SliverToBoxAdapter(child: ScrollableServiceLoading());
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                  child: Text(
                'Carwashes near you',
                style: kStyle20W500,
              )),
            ),
            BlocConsumer<StoreListBloc, StoreListState>(
                listener: (_, state) {
                  if (state is StoreListLoaded) {
                    _refreshController.refreshCompleted();
                  }
                },
                bloc: _storeListBloc,
                builder: (context, state) {
                  if (state is StoreListLoaded ||
                      state is MoreStoreListLoading) {
                    if (state is StoreListLoaded) {
                      stores = state.stores;
                    }
                    return SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (_, index) {
                        var store = stores[index];
                        var tile = StoreTile(
                          address: store.address!,
                          distance: store.distance!,
                          imageURL: store.thumbnail!,
                          rating: store.rating,
                          storeName: store.name,
                          startingFrom: store.servicesStart!,
                          storeSlug: store.storeSlug!,
                        );
                        if (state is MoreStoreListLoading &&
                            index == stores.length - 1) {
                          return LoadingMoreTile(tile: tile);
                        }
                        return tile;
                      },
                      childCount: stores.length,
                    ));
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate(
                      List.filled(4, StoreLoadingTile()),
                    ),
                  );
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
        elevation: 0,
        actionsIconTheme: IconThemeData(color: kPrimaryColor),
        backgroundColor: Colors.transparent,
        title: Center(
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showSnackbar(context,
                    'We currently only serve in ${locationModel.cityName}'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: kPrimaryColor,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      locationModel.cityName,
                      style: kStyle16PrimaryColor,
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
                                        style: kStyle10.copyWith(
                                            color: Colors.white),
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