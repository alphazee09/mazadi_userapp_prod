import 'package:extended_sliver/extended_sliver.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountDetailsShimmer extends StatelessWidget {
  final bool isCurrentUser;

  const AccountDetailsShimmer({
    super.key,
    required this.isCurrentUser,
  });

  Widget _renderHeroForAccount(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Shimmer.fromColors(
            baseColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_2,
            highlightColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            child: Container(
              margin: const EdgeInsets.only(top: 77),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipOval(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_1,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Column(children: [
                            Container(
                              width: 50,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              height: 4,
                            ),
                            Container(
                              width: 50,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ]),
                        ],
                      ),
                      Row(
                        children: [
                          Column(children: [
                            Container(
                              width: 50,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Container(
                              height: 4,
                            ),
                            Container(
                              width: 50,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 24,
                  ),
                  Row(
                    children: [
                      isCurrentUser
                          ? Container()
                          : Expanded(
                              child: Container(
                                height: 36,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .fontColor_1,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                      Container(
                        width: 8,
                      ),
                      Expanded(
                        child: Container(
                          height: 36,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _renderHeroSection(BuildContext context) {
    return Container(
      color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
      child: Column(children: [
        Container(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_3,
          width: double.infinity,
          height: 250,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            alignment: AlignmentDirectional.center,
            children: [
              Positioned(
                top: -20,
                left: -20,
                child: ClipRRect(
                  child: SizedBox(
                    height: 450,
                    width: Get.width * 1.4,
                    child: null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _renderHeroForAccount(context),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _renderAuctions(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).extension<CustomThemeFields>()!.background_3,
      highlightColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      child: Container(
        margin: const EdgeInsetsDirectional.only(start: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 250,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .fontColor_2,
              ),
            ),
            Container(
              height: 16,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Container(
                    height: 200,
                    width: 160,
                    margin: const EdgeInsetsDirectional.only(end: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_2,
                    ),
                  ),
                  Container(
                    height: 200,
                    width: 160,
                    margin: const EdgeInsetsDirectional.only(end: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_2,
                    ),
                  ),
                  Container(
                    height: 200,
                    width: 160,
                    margin: const EdgeInsetsDirectional.only(end: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_2,
                    ),
                  ),
                  Container(
                    height: 200,
                    width: 160,
                    margin: const EdgeInsetsDirectional.only(end: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderBody(BuildContext context) {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    return NestedScrollView(
      headerSliverBuilder: ((context, innerBoxIsScrolled) {
        return [
          ExtendedSliverAppbar(
            statusbarHeight: 1,
            toolBarColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            leading: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Material(
                    color: Colors.transparent,
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
                Shimmer.fromColors(
                  baseColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_2,
                  highlightColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
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
            background: IntrinsicHeight(
              child: _renderHeroSection(context),
            ),
          ),
        ];
      }),
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                ),
                _renderAuctions(context),
                Container(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _renderBody(context),
      ),
    );
  }
}
