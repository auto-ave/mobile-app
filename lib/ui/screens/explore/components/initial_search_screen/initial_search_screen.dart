import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:themotorwash/blocs/search_services/search_services_bloc.dart';
import 'package:themotorwash/data/repos/repository.dart';
import 'package:themotorwash/theme_constants.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/explore_services_grid.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/explore_services_tile.dart';
import 'package:themotorwash/ui/screens/explore/components/explore_services/loading_widgets/explore_services_loading.dart';
import 'package:themotorwash/utils/packages/multi_sliver/multi_sliver.dart';

class InitialSearchScreen extends StatefulWidget {
  const InitialSearchScreen({Key? key}) : super(key: key);

  @override
  State<InitialSearchScreen> createState() => _InitialSearchScreenState();
}

class _InitialSearchScreenState extends State<InitialSearchScreen> {
  late final SearchServicesBloc _searchServicesBloc;
  @override
  void initState() {
    super.initState();
    _searchServicesBloc = SearchServicesBloc(
        repository: RepositoryProvider.of<Repository>(context));
    _searchServicesBloc.add(
        SearchServices(query: '', forLoadMore: false, offset: 0, pageLimit: 6));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchServicesBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(),
        ), // Work around for an error. Visit : https://github.com/flutter/flutter/issues/25861 BlocBuilder cannot be the first child of a CustomScrollView
        BlocBuilder<SearchServicesBloc, SearchServicesState>(
          bloc: _searchServicesBloc,
          builder: (context, state) {
            if (state is LoadingSearchServicesResult) {
              return ExploreServicesGridLoading();
            }
            if (state is SearchedServicesResult) {
              return state.searchedServices.isNotEmpty
                  ? InitialSearchServicesGrid(
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
      ],
    );
  }
}

class InitialSearchServicesGrid extends StatelessWidget {
  final List<ExploreServiceTile> items;
  const InitialSearchServicesGrid({Key? key, required this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSliver(children: [
      SliverPadding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 16),
        sliver: SliverToBoxAdapter(
          child: Text(
            'Trending',
            style: SizeConfig.kStyle16W500,
          ),
        ),
      ),
      // SliverStaggeredGrid.count(
      //   crossAxisCount: 3,
      //   children: items.sublist(2),
      //   staggeredTiles:
      //       items.sublist(2).map((e) => StaggeredTile.fit(1)).toList(),
      // )
      // // SliverGrid(
      // //     delegate: SliverChildListDelegate(items),
      // //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      // //       mainAxisExtent: 130,
      // //       mainAxisSpacing: 16,
      // //       crossAxisCount: 3,
      // //     ))
      // SliverGrid.count(
      //   crossAxisCount: 3,
      //   children: items,
      //   mainAxisSpacing: 8,
      //   crossAxisSpacing: 0,
      //   childAspectRatio: 1,
      // ),
      Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 32,
          // alignment: WrapAlignment.spaceAround,
          // crossAxisAlignment: WrapCrossAlignment.start,

          children: items
              .map((e) => Padding(
                    padding: EdgeInsets.all(0),
                    child: e,
                  ))
              .toList(),
        ),
      ),
      SizeConfig.kverticalMargin16,
    ]);
  }
}
