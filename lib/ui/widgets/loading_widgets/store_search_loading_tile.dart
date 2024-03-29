import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:themotorwash/theme_constants.dart';

class StoreSearchLoadingTile extends StatelessWidget {
  const StoreSearchLoadingTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: SizeConfig.kShimmerBaseColor!,
            highlightColor: SizeConfig.kShimmerHighlightColor!,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: SizeConfig.kShimmerBaseColor,
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: SizeConfig.kShimmerBaseColor!,
                  highlightColor: SizeConfig.kShimmerHighlightColor!,
                  child: Container(
                    height: 20,
                    width: 150,
                    color: SizeConfig.kShimmerBaseColor,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Shimmer.fromColors(
                  baseColor: SizeConfig.kShimmerBaseColor!,
                  highlightColor: SizeConfig.kShimmerHighlightColor!,
                  child: Container(
                    height: 20,
                    width: 30,
                    color: SizeConfig.kShimmerBaseColor,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Shimmer.fromColors(
                  baseColor: SizeConfig.kShimmerBaseColor!,
                  highlightColor: SizeConfig.kShimmerHighlightColor!,
                  child: Container(
                    height: 20,
                    width: 100,
                    color: SizeConfig.kShimmerBaseColor,
                  ),
                ),
              ],
            ),
          ),
          Shimmer.fromColors(
            baseColor: SizeConfig.kShimmerBaseColor!,
            highlightColor: SizeConfig.kShimmerHighlightColor!,
            child: Container(
              height: 20,
              width: 50,
              color: SizeConfig.kShimmerBaseColor,
            ),
          ),
        ],
      ),
    );
  }
}
