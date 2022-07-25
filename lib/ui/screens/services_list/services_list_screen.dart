import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:themotorwash/blocs/search_services/search_services_bloc.dart';
import 'package:themotorwash/data/models/service.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/explore_services_grid.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/explore_services_tile.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/loading_widgets/explore_services_loading.dart';
import 'package:themotorwash/ui/screens/services_list/components/services_grid.dart';
import 'package:themotorwash/ui/widgets/error_widget.dart';
import 'package:themotorwash/utils/utils.dart';

class ServicesListScreen extends StatefulWidget {
  static final String routeName = '/services_list';
  const ServicesListScreen({Key? key}) : super(key: key);

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  late SearchServicesBloc _privateSearchServicesBloc;
  List<ServiceModel> services = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Repository repository = RepositoryProvider.of<Repository>(context);
    _privateSearchServicesBloc = SearchServicesBloc(repository: repository);
    _privateSearchServicesBloc.add(SearchServices(
        query: '', forLoadMore: false, offset: 0, pageLimit: 20));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _privateSearchServicesBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LazyLoadScrollView(
          onEndOfPage: () {
            if (_privateSearchServicesBloc.hasReachedMax(
                _privateSearchServicesBloc.state, true)) {
              if (_privateSearchServicesBloc.state is SearchedServicesResult) {
                _privateSearchServicesBloc.add(SearchServices(
                    query: '',
                    forLoadMore: true,
                    offset: services.length,
                    pageLimit: 10));
              }
            }
          },
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(),
              BlocConsumer<SearchServicesBloc, SearchServicesState>(
                listener: (_, state) {
                  if (state is SearchedServicesResult) {
                    setState(() {});
                  }
                },
                bloc: _privateSearchServicesBloc,
                builder: (context, state) {
                  if (state is LoadingSearchServicesResult) {
                    return ExploreServicesGridLoading();
                  }
                  if (state is SearchedServicesResult ||
                      state is LoadingMoreSearchServicesResult) {
                    // autoaveLog(state.searchedServices.toString());
                    if (state is SearchedServicesResult) {
                      services = state.searchedServices;
                    }
                    return services.isNotEmpty
                        ? ServicesGrid(
                            items: services
                                .map((e) => ExploreServiceTile(
                                      imageUrl: e.thumbnail!,
                                      serviceName: e.name!,
                                      serviceTag: e.slug!,
                                      bannerUrl: e.bannerUrl ??
                                          SizeConfig.autoaveBanner,
                                    ))
                                .toList(),
                            isLoadingMore:
                                state is LoadingMoreSearchServicesResult,
                          )
                        : SliverToBoxAdapter(child: Container());
                  }
                  if (state is SearchedServicesError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: ErrorScreen(
                          ctaType: ErrorCTA.reload,
                          onCTAPressed: () {
                            _privateSearchServicesBloc.add(SearchServices(
                                query: '',
                                forLoadMore: false,
                                offset: 0,
                                pageLimit: 20));
                          },
                        ),
                      ),
                    );
                  }

                  return ExploreServicesGridLoading();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
