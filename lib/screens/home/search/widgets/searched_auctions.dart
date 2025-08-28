import 'dart:convert';

import 'package:mazadi/core/models/auction.dart';
import 'package:mazadi/screens/auction-details/index.dart';

import 'package:mazadi/widgets/common/section_heading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/models/search_history_item.dart';
import '../../../../core/navigator.dart';
import '../../../../core/controllers/search.dart' as search_ctrl;
import 'searched_auctions_item.dart';

// ignore: must_be_immutable
class SearchedAuctions extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final searchController = Get.find<search_ctrl.SearchController>();

  List<Auction> auctions;
  String userQuery;
  BuildContext ctx;

  SearchedAuctions({
    required this.auctions,
    required this.userQuery,
    required this.ctx,
  });

  Widget _renderNoAuctionsFound() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'home.search.no_auction_that_match',
              style: Theme.of(ctx).extension<CustomThemeFields>()!.smaller,
              textAlign: TextAlign.center,
            ).tr(),
          )
        ],
      ),
    );
  }

  Widget _renderSuggestionItem(Auction auction) {
    return SearchedAuctionsSuggestionItem(
      auction: auction,
      ctx: ctx,
      onTap: () {
        searchController.addSearchHistoryItem(
          SearchHistoryItemType.auction,
          userQuery,
          jsonEncode(auction.toJson()),
          auction.id,
        );

        navigatorService.push(
          AuctionDetailsScreen(
            auctionId: auction.id,
            assetsLen: auction.assets?.length ?? 1,
          ),
          NavigationStyle.SharedAxis,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
        ),
        SectionHeading(
          title: tr('home.auctions.auctions'),
          ctx: ctx,
          withMore: auctions.isNotEmpty && auctions.length > 5,
        ),
        auctions.isEmpty ? _renderNoAuctionsFound() : Container(),
        for (var auction in auctions.take(5)) _renderSuggestionItem(auction)
      ],
    );
  }
}
