import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:themotorwash/blocs/global_vehicle_type/bloc/global_vehicle_type_bloc.dart';
import 'package:themotorwash/blocs/vehicle_type_functions/vehicle_type_functions_bloc.dart';
import 'package:themotorwash/blocs/vehicle_type_list/bloc/vehicle_type_list_bloc.dart';
import 'package:themotorwash/data/local/local_data_service.dart';
import 'package:themotorwash/data/models/vehicle_brand.dart';
import 'package:themotorwash/data/models/vehicle_model.dart';
import 'package:themotorwash/data/models/vehicle_wheel.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/main.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/widgets/search_bar.dart';
import 'package:themotorwash/utils/utils.dart';

class VehicleTypeSelectionBottomSheet extends StatefulWidget {
  final PageController pageController;

  const VehicleTypeSelectionBottomSheet(
      {Key? key, required this.pageController})
      : super(key: key);

  @override
  _VehicleTypeSelectionBottomSheetState createState() =>
      _VehicleTypeSelectionBottomSheetState();
}

class _VehicleTypeSelectionBottomSheetState
    extends State<VehicleTypeSelectionBottomSheet> {
  late VehicleTypeFunctionsBloc _vehicleTypeFunctionsBloc;
  late GlobalVehicleTypeBloc _globalVehicleTypeBloc;
  late LocalDataService _localDataService;
  late VehicleListBloc _vehicleTypeListBloc;
  late VehicleWheel selectedWheel;
  late VehicleBrand selectedBrand;

  @override
  void initState() {
    super.initState();
    _globalVehicleTypeBloc =
        BlocProvider.of<GlobalVehicleTypeBloc>(context, listen: false);
    _localDataService = GetIt.instance.get<LocalDataService>(
        instanceName: LocalDataService.getItInstanceName);
    _vehicleTypeFunctionsBloc = VehicleTypeFunctionsBloc(
        globalVehicleTypeBloc: _globalVehicleTypeBloc,
        localDataService: _localDataService);
    _vehicleTypeListBloc =
        VehicleListBloc(repository: RepositoryProvider.of<Repository>(context));
    _vehicleTypeListBloc.add(LoadVehicleTypeList());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _vehicleTypeFunctionsBloc.close();
    _vehicleTypeListBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).padding.top);
    return WillPopScope(
      onWillPop: () async {
        int? pageIndex = widget.pageController.page != null
            ? widget.pageController.page!.toInt()
            : null;
        if (widget.pageController.page != 0) {
          widget.pageController.animateToPage(
              pageIndex != null && pageIndex != 0 ? pageIndex - 1 : 0,
              duration: Duration(milliseconds: 300),
              curve: Curves.linear);
          return false;
        } else {
          return true;
        }
      },
      child: DraggableScrollableSheet(
          initialChildSize: .8,
          // expand: true,
          builder: (_, __) {
            return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                  ),
                  child: PageView.custom(
                    onPageChanged: (index) {
                      setState(() {});
                    },
                    physics: NeverScrollableScrollPhysics(),
                    controller: widget.pageController,
                    childrenDelegate: SliverChildBuilderDelegate((ctx, index) {
                      if (index == 0) {
                        return VehicleWheelSelectionPage(
                            onWheelTapped: (wheel) {
                          selectedWheel = wheel;
                          widget.pageController.animateToPage(1,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear);
                        });
                      } else if (index == 1) {
                        return VehicleBrandSelectionPage(
                          onBrandTapped: (brand) {
                            selectedBrand = brand;
                            widget.pageController.animateToPage(2,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.linear);
                          },
                          selectedWheel: selectedWheel,
                          onBackPressed: () {
                            widget.pageController.animateToPage(0,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.linear);
                          },
                        );
                      } else {
                        return VehicleModelSelectionPage(
                          onVehicleModelTapped: (model) {
                            _vehicleTypeFunctionsBloc.add(
                                SelectVehicleType(vehicleTypeModel: model));
                            Navigator.pop(context);
                          },
                          selectedBrand: selectedBrand,
                          onBackPressed: () {
                            widget.pageController.animateToPage(1,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.linear);
                          },
                        );
                      }
                    }, childCount: 3, addAutomaticKeepAlives: false),
                  ),
                ));
          }),
    );
  }
}

class VehicleWheelSelectionPage extends StatefulWidget {
  final Function(VehicleWheel wheelIndex) onWheelTapped;
  const VehicleWheelSelectionPage({
    Key? key,
    required this.onWheelTapped,
  }) : super(key: key);

  @override
  _VehicleWheelSelectionPageState createState() =>
      _VehicleWheelSelectionPageState();
}

class _VehicleWheelSelectionPageState extends State<VehicleWheelSelectionPage>
    with AutomaticKeepAliveClientMixin<VehicleWheelSelectionPage> {
  late final vehicleListBloc;
  @override
  void initState() {
    super.initState();
    vehicleListBloc =
        VehicleListBloc(repository: RepositoryProvider.of<Repository>(context));
    vehicleListBloc.add(LoadVehicleWheelList());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your vehicle type',
            style: SizeConfig.kStyle20W500,
          ),
          SizeConfig.kverticalMargin32,
          BlocBuilder<VehicleListBloc, VehicleListState>(
            bloc: vehicleListBloc,
            builder: (context, state) {
              if (state is VehicleWheelListLoaded) {
                var wheels = state.wheels;
                return Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        // runAlignment: WrapAlignment.spaceAround,
                        // crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: wheels
                            .map((e) => VehicleWheelWidget(
                                wheel: e, onTap: widget.onWheelTapped))
                            .toList(),
                      ),
                    ));
                return GridView.builder(
                  itemCount: wheels.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 100),
                  itemBuilder: (ctx, index) {
                    VehicleWheel wheel = wheels[index];
                    return VehicleWheelWidget(
                        wheel: wheel, onTap: widget.onWheelTapped);
                    // (wheelTapped) {
                    //   setState(() {
                    //     selectedWheel = wheelTapped;
                    //     widget.pageController.animateToPage(1,
                    //         duration: Duration(milliseconds: 300),
                    //         curve: Curves.linear);
                    //   });
                    // });
                  },
                );
              }
              return Center(
                child: loadingAnimation(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}

class VehicleWheelWidget extends StatelessWidget {
  final VehicleWheel wheel;
  final Function(VehicleWheel wheel) onTap;
  const VehicleWheelWidget({Key? key, required this.wheel, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(wheel),
      child: Container(
        width: SizeConfig.screenWidth * .4, // height: 150,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(
              color: SizeConfig.kPrimaryColor,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                  offset: Offset(-5, 4),
                  blurRadius: 16,
                  color: Color.fromRGBO(0, 0, 0, 0.16))
            ]),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                // color: Colors.amber,
                child: CachedNetworkImage(
                  imageUrl: wheel.imageUrl,
                  // width: 80,
                  // height: 50,
                  width: 80,
                  height: 80,
                  // height: 80,
                ),
              ),

              // SizeConfig.kverticalMargin8,
              Text(
                wheel.name,
                maxLines: 1,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class VehicleBrandSelectionPage extends StatefulWidget {
  final VehicleWheel selectedWheel;
  final Function(VehicleBrand brand) onBrandTapped;
  final VoidCallback onBackPressed;
  const VehicleBrandSelectionPage(
      {Key? key,
      required this.selectedWheel,
      required this.onBrandTapped,
      required this.onBackPressed})
      : super(key: key);

  @override
  _VehicleBrandSelectionPageState createState() =>
      _VehicleBrandSelectionPageState();
}

class _VehicleBrandSelectionPageState extends State<VehicleBrandSelectionPage>
    with AutomaticKeepAliveClientMixin<VehicleBrandSelectionPage> {
  late final vehicleListBloc;
  FocusNode focusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  List<VehicleBrand> brands = [];
  List<VehicleBrand> filteredBrands = [];

  @override
  void initState() {
    super.initState();
    vehicleListBloc =
        VehicleListBloc(repository: RepositoryProvider.of<Repository>(context));
    vehicleListBloc
        .add(LoadVehicleBrandList(wheelCode: widget.selectedWheel.code));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBackPressed,
              ),
              SizeConfig.kHorizontalMargin8,
              Expanded(
                child: Text(
                  'Select your vehicle brand',
                  style: SizeConfig.kStyle20W500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizeConfig.kverticalMargin32,
          SearchBar(
            focusNode: focusNode,
            onChanged: (query) {
              print('query ' + query);
              filteredBrands = [];
              brands.forEach((element) {
                if (element.name.toLowerCase().contains(query.toLowerCase())) {
                  filteredBrands.add(element);
                  print('brand found');
                } else {
                  print('falseeee');
                }
              });

              setState(() {});
            },
            textController: searchController,
            hintText: 'Search Brands',
          ),
          SizeConfig.kverticalMargin16,
          Expanded(
              child: BlocBuilder<VehicleListBloc, VehicleListState>(
            // listener: (context, state) {
            //   if (state is VehicleBrandListLoaded) {
            //     // setState(() {
            //     //   // filteredBrands = state.brands;
            //     // });
            //   }
            // },
            bloc: vehicleListBloc,
            builder: (context, state) {
              if (state is VehicleBrandListLoaded) {
                brands = state.brands;
                if (searchController.text.isEmpty) {
                  filteredBrands = brands;
                }

                return Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      // runAlignment: WrapAlignment.spaceAround,
                      // crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: filteredBrands
                          .map((e) => VehicleBrandWidget(
                              brand: e, onTap: widget.onBrandTapped))
                          .toList(),
                    ),
                  ),
                );
              }
              return Center(
                child: loadingAnimation(),
              );
            },
          )),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}

class VehicleBrandWidget extends StatelessWidget {
  final VehicleBrand brand;
  final Function(VehicleBrand brand) onTap;
  const VehicleBrandWidget({Key? key, required this.brand, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(brand),
        child: Container(
          width: SizeConfig.screenWidth * .4,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              border: Border.all(
                color: SizeConfig.kPrimaryColor,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    offset: Offset(-5, 4),
                    blurRadius: 16,
                    color: Color.fromRGBO(0, 0, 0, 0.16))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                print('max height ${constraints.maxHeight}');
                return CachedNetworkImage(
                  imageUrl: brand.imageUrl,
                  // width: 80,
                  // height: 50,
                  height: 80,
                  // width: constraints.maxWidth * .6,
                );
              }),
              // SizeConfig.kverticalMargin8,
              Text(
                brand.name,
                maxLines: 1,
              )
            ],
          ),
        ));
  }
}

class VehicleModelSelectionPage extends StatefulWidget {
  final Function(VehicleModel vehicleModel) onVehicleModelTapped;
  final VehicleBrand selectedBrand;
  final VoidCallback onBackPressed;
  const VehicleModelSelectionPage(
      {Key? key,
      required this.onVehicleModelTapped,
      required this.selectedBrand,
      required this.onBackPressed})
      : super(key: key);

  @override
  _VehicleModelSelectionPageState createState() =>
      _VehicleModelSelectionPageState();
}

class _VehicleModelSelectionPageState extends State<VehicleModelSelectionPage>
    with AutomaticKeepAliveClientMixin<VehicleModelSelectionPage> {
  late final vehicleListBloc;
  FocusNode focusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  List<VehicleModel> models = [];
  List<VehicleModel> filteredModels = [];
  @override
  void initState() {
    super.initState();
    vehicleListBloc =
        VehicleListBloc(repository: RepositoryProvider.of<Repository>(context));
    vehicleListBloc.add(LoadVehicleModelList(brand: widget.selectedBrand.name));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBackPressed,
              ),
              SizeConfig.kHorizontalMargin8,
              Expanded(
                child: Text(
                  'Select your vehicle model',
                  style: SizeConfig.kStyle20W500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizeConfig.kverticalMargin32,
          SearchBar(
            focusNode: focusNode,
            onChanged: (query) {
              print('query ' + query);
              filteredModels = [];
              models.forEach((element) {
                if (element.model!
                    .toLowerCase()
                    .contains(query.toLowerCase())) {
                  filteredModels.add(element);
                  print('brand found');
                } else {
                  print('falseeee');
                }
              });

              setState(() {});
            },
            textController: searchController,
            hintText: 'Search Models',
          ),
          SizeConfig.kverticalMargin16,
          Expanded(
            child: BlocBuilder<VehicleListBloc, VehicleListState>(
              bloc: vehicleListBloc,
              builder: (context, state) {
                if (state is VehicleModelListLoaded) {
                  models = state.vehicles;
                  if (searchController.text.isEmpty) {
                    filteredModels = models;
                  }
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Wrap(
                        // alignment: WrapAlignment.end,
                        // runAlignment: WrapAlignment.end,
                        // crossAxisAlignment: WrapCrossAlignment.end,

                        spacing: 16,
                        runSpacing: 16,
                        children: filteredModels
                            .map((e) => VehicleModelWidget(
                                vehicleModel: e,
                                onTap: widget.onVehicleModelTapped))
                            .toList(),
                      ),
                    ),
                  );
                  return GridView.builder(
                    itemCount: filteredModels.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 100),
                    itemBuilder: (ctx, index) {
                      VehicleModel vehicle = filteredModels[index];
                      return VehicleModelWidget(
                          vehicleModel: vehicle,
                          onTap: widget.onVehicleModelTapped);
                    },
                  );
                }
                return Center(
                  child: loadingAnimation(),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => false;
}

class VehicleModelWidget extends StatelessWidget {
  final VehicleModel vehicleModel;
  final Function(VehicleModel vehicleModel) onTap;
  const VehicleModelWidget({
    Key? key,
    required this.vehicleModel,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(vehicleModel),
        child: Container(
          padding: EdgeInsets.all(8),
          width: SizeConfig.screenWidth * .4,
          decoration: BoxDecoration(
              border: Border.all(
                color: SizeConfig.kPrimaryColor,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                    offset: Offset(-5, 4),
                    blurRadius: 16,
                    color: Color.fromRGBO(0, 0, 0, 0.16))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: vehicleModel.image!,
                // width: 80,
                height: 80,
              ),
              Text(
                vehicleModel.model!,
                // maxLines: 1,
              )
            ],
          ),
        ));
  }
}
