import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masonry_grid/masonry_grid.dart';
import 'package:shimmer/shimmer.dart';

class AuctionsListShimmer extends StatelessWidget {
  final int auctionsCount;

  AuctionsListShimmer({
    super.key,
    required this.auctionsCount,
  });

  Widget _renderGridCard(BuildContext context) {
    return Container(
      height: 264,
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Shimmer.fromColors(
          baseColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_2,
          highlightColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: MasonryGrid(
            column: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              for (var i = 0; i < auctionsCount; i++) _renderGridCard(context)
            ],
          ),
        ),
      ),
    );
  }
}
