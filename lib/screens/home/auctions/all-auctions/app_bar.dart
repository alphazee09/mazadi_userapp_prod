import 'package:mazadi/core/controllers/auction.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/navigator.dart';
import '../../../../widgets/auctions_list_sort_popup.dart';
import '../../../../widgets/simple_app_bar.dart';
import '../../filter/index.dart';

class AllAuctionsAppBar extends StatefulWidget {
  final Widget child;
  final bool? loadingData;
  final Function? onScrollBottom;
  final Function? onSearchKeyUpdate;
  final Function? onSort;

  const AllAuctionsAppBar({
    super.key,
    required this.child,
    this.loadingData,
    this.onScrollBottom,
    this.onSearchKeyUpdate,
    this.onSort,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilteredAuctionsSimpleAppBar createState() =>
      _FilteredAuctionsSimpleAppBar();
}

class _FilteredAuctionsSimpleAppBar extends State<AllAuctionsAppBar> {
  final navigatorService = Get.find<NavigatorService>();
  final auctionController = Get.find<AuctionController>();

  final Rx<bool> _pointerDownInner = false.obs;

  void goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          if (_pointerDownInner.value) {
            _pointerDownInner.value = false;
            return;
          }

          _pointerDownInner.value = false;
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            var nextPageTrigger = 0.8 * scrollInfo.metrics.maxScrollExtent;

            if (scrollInfo.metrics.pixels > nextPageTrigger) {
              // here you update your data or load your data from network
              if (widget.onScrollBottom != null) {
                widget.onScrollBottom!();
              }
            }
            return true;
          },
          // if you used network it would good to use the stream or future builder
          child: Scaffold(
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            resizeToAvoidBottomInset: true,
            appBar: SimpleAppBar(
              handleSearchInputTapDown: () {
                _pointerDownInner.value = true;
              },
              onBack: () {
                goBack();
              },
              isLoading: widget.loadingData ?? false,
              withClearSearchKey: true,
              withSearch: true,
              sufixIcon: Container(
                margin: EdgeInsetsDirectional.only(end: 4),
                child: IconButton(
                  onPressed: () {
                    navigatorService.push(const HomeFilterScreen());
                  },
                  icon: SvgPicture.asset(
                    'assets/icons/svg/filter.svg',
                    height: 26,
                    semanticsLabel: 'Filter',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              handleSearch: (String key) {
                if (widget.onSearchKeyUpdate != null) {
                  widget.onSearchKeyUpdate!(key);
                }
              },
              handleFilterTap: () {
                navigatorService.push(const HomeFilterScreen());
              },
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          child: Obx(
                            () => Row(
                              children: [
                                Text(
                                  'home.auctions.all_auctions',
                                  textAlign: TextAlign.start,
                                  style: Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .title,
                                ).tr(namedArgs: {
                                  'no': auctionController
                                      .allActiveAuctionsCount.value
                                      .toString()
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsetsDirectional.only(end: 16),
                        child: Row(
                          children: [
                            AuctionsListSortPopup(
                              handleSort: widget.onSort,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
            body: widget.child,
          ),
        ),
      ),
    );
  }
}
