import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../core/controllers/search.dart' as search_ctrl;
import '../../../../core/navigator.dart';
import '../../../../widgets/common/section_heading.dart';
import '../../../../widgets/common/simple_button.dart';
import 'recent_search_item.dart';
import 'recent_searches_paginated.dart';

class RecentSearches extends StatefulWidget {
  final Color? background;
  final BuildContext ctx;
  final ThemeData theme;

  const RecentSearches({
    super.key,
    required this.ctx,
    required this.theme,
    this.background,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RecentSearches createState() => _RecentSearches();
}

class _RecentSearches extends State<RecentSearches> {
  final navigatorService = Get.find<NavigatorService>();
  final searchController = Get.find<search_ctrl.SearchController>();

  void goToMore() {
    navigatorService.push(
      RecentSearchesPaginated(
        ctx: widget.ctx,
        historyItems: searchController.userSearches,
      ),
      NavigationStyle.SharedAxis,
    );
  }

  Widget _renderSeeMoreButton() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SimpleButton(
              width: Get.width / 1.5,
              onPressed: () {
                goToMore();
              },
              background: Theme.of(widget.ctx)
                  .extension<CustomThemeFields>()!
                  .background_1,
              child: Text(
                'generic.see_more',
                style: Theme.of(widget.ctx)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
              ).tr(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var userSearches = searchController.userSearches.take(5);

    return Theme(
      data: widget.theme,
      child: Container(
        width: double.infinity,
        color:
            Theme.of(widget.ctx).extension<CustomThemeFields>()!.background_1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
            ),
            userSearches.isEmpty
                ? Container()
                : SectionHeading(
                    title: tr('home.search.recent_searches'),
                    withMore: true,
                    onPressed: () {
                      goToMore();
                    },
                  ),
            userSearches.isEmpty
                ? SizedBox(
                    width: Get.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 32,
                        ),
                        SvgPicture.asset(
                          'assets/icons/categories/all.svg',
                          height: 120,
                          semanticsLabel: 'Search auctions',
                        ),
                        Container(
                          height: 32,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Text(
                            'home.search.search',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: Theme.of(widget.ctx)
                                .extension<CustomThemeFields>()!
                                .title
                                .copyWith(
                                  fontWeight: FontWeight.w300,
                                ),
                          ).tr(),
                        ),
                        Container(
                          height: 32,
                        ),
                      ],
                    ),
                  )
                : Container(),
            for (var searchItem in userSearches)
              RecentSearchItemWidget(
                ctx: widget.ctx,
                item: searchItem,
              ),
            searchController.userSearches.length >= 5
                ? _renderSeeMoreButton()
                : Container()
          ],
        ),
      ),
    );
  }
}
