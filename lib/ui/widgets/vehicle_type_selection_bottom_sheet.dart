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
import 'package:themotorwash/utils.dart';

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
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).padding.top);
    return WillPopScope(
      onWillPop: () async {
        if (widget.pageController.page != 0) {
          widget.pageController.animateToPage(0,
              duration: Duration(milliseconds: 300), curve: Curves.linear);
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
                  child: PageView.builder(
                    onPageChanged: (index) {
                      setState(() {});
                    },
                    physics: NeverScrollableScrollPhysics(),
                    controller: widget.pageController,
                    itemBuilder: (ctx, index) {
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
                        );
                      } else {
                        return VehicleModelSelectionPage(
                          onVehicleModelTapped: (model) {
                            _vehicleTypeFunctionsBloc.add(
                                SelectVehicleType(vehicleTypeModel: model));
                            Navigator.pop(context);
                          },
                          selectedBrand: selectedBrand,
                        );
                      }
                    },
                    itemCount: 3,
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

class _VehicleWheelSelectionPageState extends State<VehicleWheelSelectionPage> {
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
          Expanded(
              child: BlocBuilder<VehicleListBloc, VehicleListState>(
            bloc: vehicleListBloc,
            builder: (context, state) {
              if (state is VehicleWheelListLoaded) {
                var wheels = state.wheels;
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
          )),
        ],
      ),
    );
  }
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
            CachedNetworkImage(
              imageUrl: wheel.imageUrl,
              width: 80,
              height: 50,
            ),
            SizeConfig.kverticalMargin8,
            Text(wheel.name)
          ],
        ),
      ),
    );
  }
}

class VehicleBrandSelectionPage extends StatefulWidget {
  final VehicleWheel selectedWheel;
  final Function(VehicleBrand brand) onBrandTapped;
  const VehicleBrandSelectionPage({
    Key? key,
    required this.selectedWheel,
    required this.onBrandTapped,
  }) : super(key: key);

  @override
  _VehicleBrandSelectionPageState createState() =>
      _VehicleBrandSelectionPageState();
}

class _VehicleBrandSelectionPageState extends State<VehicleBrandSelectionPage> {
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
          Text(
            'Select your vehicle brand',
            style: SizeConfig.kStyle20W500,
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
                return GridView.builder(
                  itemCount: filteredBrands.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 100),
                  itemBuilder: (ctx, index) {
                    VehicleBrand brand = filteredBrands[index];
                    return VehicleBrandWidget(
                        brand: brand, onTap: widget.onBrandTapped);
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
          )),
        ],
      ),
    );
  }
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
              CachedNetworkImage(
                imageUrl: brand.imageUrl,
                width: 80,
                height: 50,
              ),
              SizeConfig.kverticalMargin8,
              Text(brand.name)
            ],
          ),
        ));
  }
}

class VehicleModelSelectionPage extends StatefulWidget {
  final Function(VehicleModel vehicleModel) onVehicleModelTapped;
  final VehicleBrand selectedBrand;
  const VehicleModelSelectionPage({
    Key? key,
    required this.onVehicleModelTapped,
    required this.selectedBrand,
  }) : super(key: key);

  @override
  _VehicleModelSelectionPageState createState() =>
      _VehicleModelSelectionPageState();
}

class _VehicleModelSelectionPageState extends State<VehicleModelSelectionPage> {
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
          Text(
            'Select your vehicle model',
            style: SizeConfig.kStyle20W500,
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
          )),
        ],
      ),
    );
  }
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
                width: 80,
                height: 50,
              ),
              SizeConfig.kverticalMargin8,
              Text(vehicleModel.model!)
            ],
          ),
        ));
  }
}
