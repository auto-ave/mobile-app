import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:themotorwash/blocs/cart/cart_function_bloc.dart';
import 'package:themotorwash/blocs/global_auth/global_auth_bloc.dart';
import 'package:themotorwash/blocs/global_vehicle_type/bloc/global_vehicle_type_bloc.dart';
import 'package:themotorwash/blocs/order_review/order_review_bloc.dart';
import 'package:themotorwash/data/models/price_time_list_model.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/store_detail/blocs/store_services/store_services_bloc.dart';
import 'package:themotorwash/ui/screens/store_detail/components/store_service_tile.dart';
import 'package:themotorwash/ui/widgets/common_button.dart';
import 'package:themotorwash/ui/widgets/loading_more_tile.dart';
import 'package:themotorwash/ui/widgets/loading_widgets/shimmer_placeholder.dart';
import 'package:themotorwash/ui/widgets/vehicle_dropdown.dart';
import 'package:themotorwash/ui/widgets/vehicle_type_selection_bottom_sheet.dart';
import 'package:themotorwash/utils.dart';

class StoreServicesTab extends StatefulWidget {
  final BuildContext nestedScrollContext;
  final String storeSlug;
  final GlobalKey<ScaffoldState> scaffoldState;

  StoreServicesTab(
      {required this.nestedScrollContext,
      required this.storeSlug,
      required this.scaffoldState});

  @override
  _StoreServicesTabState createState() => _StoreServicesTabState();
}

class _StoreServicesTabState extends State<StoreServicesTab> {
  final PageController pageController = PageController();
  late StoreServicesBloc _servicesBloc;
  late CartFunctionBloc _cartFunctionBloc;
  late GlobalAuthBloc _globalAuthBloc;
  late GlobalVehicleTypeBloc _globalVehicleTypeBloc;
  late OrderReviewBloc _orderReviewBloc;

  List<PriceTimeListModel> services = [];
  List<int> cartItems = [];
  @override
  void initState() {
    super.initState();
    _globalVehicleTypeBloc = BlocProvider.of<GlobalVehicleTypeBloc>(context);
    _servicesBloc = StoreServicesBloc(
        repository: RepositoryProvider.of<Repository>(context));
    _orderReviewBloc = BlocProvider.of<OrderReviewBloc>(context, listen: false);
    _cartFunctionBloc = BlocProvider.of<CartFunctionBloc>(context);
    _globalVehicleTypeBloc.add(CheckSavedVehicleType());
    _globalAuthBloc = BlocProvider.of<GlobalAuthBloc>(context);
    print('hello reached here10');
  }

  String? _selectedFilter;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalVehicleTypeBloc, GlobalVehicleTypeState>(
      bloc: _globalVehicleTypeBloc,
      listener: (ctx, vehicleState) {
        print('hello reached here0');

        if (vehicleState is VehicleTypeNotSelected) {
          print('hello reached here1');
          _showVehicleBottomSheet(context);
        }
        if (vehicleState is GlobalVehicleTypeSelected) {
          showSnackbar(context, 'Vehicle Type Selected');
          _servicesBloc.add(LoadStoreServices(
              slug: widget.storeSlug,
              vehicleType: vehicleState.vehicleTypeModel.model,
              offset: 0,
              forLoadMore: false));
        }
        if (vehicleState is GlobalVehicleTypeError) {
          showSnackbar(context, 'Error Loading Vehicle Type');
        }
      },
      builder: (ctx, vehicleState) {
        return vehicleState is GlobalVehicleTypeSelected
            ? _buildServicesList(vehicleState)
            : _buildSelectVehicleTypeButton();
      },
    );
  }

  _buildServicesList(GlobalVehicleTypeSelected vehicleState) {
    return LazyLoadScrollView(
      onEndOfPage: _servicesBloc.state is StoreServicesLoaded
          ? () {}
          : () {
              if (_servicesBloc.state is StoreServicesLoaded) {
                _servicesBloc.add(LoadStoreServices(
                    slug: widget.storeSlug,
                    vehicleType: vehicleState.vehicleTypeModel.model,
                    offset: services.length,
                    forLoadMore: true));
              }
            },
      child: CustomScrollView(slivers: <Widget>[
        SliverOverlapInjector(
          // This is the flip side of the SliverOverlapAbsorber
          // above.
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
              widget.nestedScrollContext),
        ),
        SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: kPrimaryColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 8,
                        offset: Offset(0, 0))
                  ],
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELECTED VEHICLE',
                        style: kStyle12.copyWith(
                            color: Color(0xff696969), letterSpacing: 1.8),
                      ),
                      kverticalMargin8,
                      Row(
                        children: [
                          RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(children: [
                              TextSpan(
                                text: vehicleState.vehicleTypeModel.wheel,
                                style: kStyle16.copyWith(color: Colors.black),
                              ),
                              TextSpan(
                                text: ' ${vehicleState.vehicleTypeModel.model}',
                                style: kStyle16PrimaryColor,
                              ),
                            ]),
                          ),
                          kHorizontalMargin8,
                          CachedNetworkImage(
                              placeholder: (_, __) {
                                return ShimmerPlaceholder();
                              },
                              width: 65,
                              imageUrl: vehicleState.vehicleTypeModel.image!),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  CommonTextButton(
                      onPressed: () => _showVehicleBottomSheet(context),
                      child: Text(
                        'Change',
                        style: kStyle12.copyWith(color: Colors.white),
                      ),
                      backgroundColor: kPrimaryColor)
                ],
              ),
            ),
          ),
        ),
        BlocBuilder<CartFunctionBloc, CartFunctionState>(
          bloc: _cartFunctionBloc,
          builder: (context, cartFunctionState) {
            if (cartFunctionState is CartItemAdded) {
              cartItems = cartFunctionState.cart.items!;
            }
            if (cartFunctionState is CartItemDeleted) {
              cartItems = cartFunctionState.cart.items!;
            }
            if (cartFunctionState is CartLoaded) {
              cartItems = cartFunctionState.cart.items!;
            }
            return BlocBuilder<StoreServicesBloc, StoreServicesState>(
              bloc: _servicesBloc,
              builder: (context, state) {
                if (state is StoreServicesLoading) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (state is StoreServicesLoaded ||
                    state is MoreStoreServicesLoading) {
                  if (state is StoreServicesLoaded) {
                    print(state.services.toString() + "he");
                    services = state.services;
                  }

                  return services.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Text("No services for selected vehicle"),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((_, index) {
                          var service = services[index];
                          var tile = StoreServiceTile(
                              time: service.timeInterval.toString(),
                              scaffoldState: widget.scaffoldState,
                              itemId: service.id!,
                              bloc: _cartFunctionBloc,
                              globalAuthBloc: _globalAuthBloc,
                              isAddedToCart:
                                  getIsAddedToCart(itemId: services[index].id!),
                              isLoading:
                                  (cartFunctionState is CartFunctionLoading &&
                                      (cartFunctionState)
                                          .itemId
                                          .contains(services[index].id!)),
                              description: services[index].description!,
                              price: service.price!.toString(),
                              service: service.service!);

                          if (state is MoreStoreServicesLoading &&
                              index == services.length - 1) {
                            return LoadingMoreTile(tile: tile);
                          }
                          return tile;
                        }, childCount: services.length));
                }
                if (state is StoreServicesError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text("Failed To Load"),
                    ),
                  );
                }
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            );
          },
        )
      ]),
    );
  }

  _buildSelectVehicleTypeButton() {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          // This is the flip side of the SliverOverlapAbsorber
          // above.
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
              widget.nestedScrollContext),
        ),
        SliverFillRemaining(
          child: Center(
              child: CommonTextButton(
                  onPressed: () => _showVehicleBottomSheet(context),
                  child: Text(
                    'Select Vehicle Type',
                    style: kStyle14.copyWith(color: Colors.white),
                  ),
                  backgroundColor: kPrimaryColor)),
        )
      ],
    );
  }

  bool getIsAddedToCart({required int itemId}) {
    return cartItems.contains(itemId);
  }

  void _showVehicleBottomSheet(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return VehicleTypeSelectionBottomSheet(
            pageController: pageController,
          );
        });
  }
}
