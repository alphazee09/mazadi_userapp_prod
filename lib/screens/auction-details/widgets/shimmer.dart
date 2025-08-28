import 'package:mazadi/theme/extensions/base.dart';
import 'package:extended_sliver/extended_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class AuctionDetailsShimmer extends StatelessWidget {
  final int assetsLen;

  const AuctionDetailsShimmer({
    super.key,
    required this.assetsLen,
  });

  Widget _renderShimmerWrapper(BuildContext context, Widget child,
      [bool secondary = false]) {
    return Shimmer.fromColors(
      baseColor: secondary
          ? Theme.of(context).extension<CustomThemeFields>()!.background_1
          : Theme.of(context).extension<CustomThemeFields>()!.background_2,
      highlightColor: secondary
          ? Theme.of(context).extension<CustomThemeFields>()!.background_2
          : Theme.of(context).extension<CustomThemeFields>()!.background_1,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    return SafeArea(
      child: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            ExtendedSliverAppbar(
              statusbarHeight: 1,
              toolBarColor: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_1,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              actions: Container(
                margin: const EdgeInsetsDirectional.only(end: 16),
                child: Row(children: [
                  Row(
                    children: [
                      _renderShimmerWrapper(
                        context,
                        Container(
                          width: 46,
                          height: 46,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .background_2
                                .withOpacity(0.9),
                          ),
                          child: Container(
                            width: 46,
                            height: 46,
                            margin: const EdgeInsetsDirectional.only(start: 8),
                            padding: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .background_2
                                  .withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                      _renderShimmerWrapper(
                        context,
                        Container(
                          width: 46,
                          height: 46,
                          margin: const EdgeInsetsDirectional.only(start: 8),
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .background_2
                                .withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  )
                ]),
              ),
              leading: Row(
                children: [
                  _renderShimmerWrapper(
                    context,
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 16),
                      child: Material(
                        shape: const CircleBorder(),
                        color: Colors.transparent,
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .background_2
                                .withOpacity(0.9),
                          ),
                          child: IconButton(
                            splashRadius: 24,
                            icon: SvgPicture.asset(
                              isRTL
                                  ? 'assets/icons/svg/next.svg'
                                  : 'assets/icons/svg/previous.svg',
                              colorFilter: ColorFilter.mode(
                                Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                BlendMode.srcIn,
                              ),
                              semanticsLabel: 'Previous',
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              background: IntrinsicHeight(
                child: Stack(
                  children: [
                    _renderShimmerWrapper(
                      context,
                      Container(
                        height: 350,
                        width: Get.width,
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_3
                            .withOpacity(0.9),
                      ),
                      true,
                    ),
                  ],
                ),
              ),
            ),
          ];
        }),
        body: SingleChildScrollView(
          child: Container(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                ),
                _renderShimmerWrapper(
                  context,
                  Container(
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Container(
                  height: 16,
                ),
                _renderShimmerWrapper(
                  context,
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: Get.width,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 36,
                    ),
                  ),
                ),
                Container(height: 16),
                _renderShimmerWrapper(
                  context,
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: Get.width,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      height: 36,
                    ),
                  ),
                ),
                Container(height: 16),
                Divider(
                  height: 16,
                  thickness: 1,
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .separator
                      .withOpacity(0.3),
                ),
                Container(height: 16),
                _renderShimmerWrapper(
                  context,
                  Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: 200,
                      height: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
