import 'dart:convert';

import 'package:mazadi/screens/auction-details/index.dart';

import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/models/account.dart';
import '../../../../core/models/auction.dart';
import '../../../../core/models/search_history_item.dart';
import '../../../../core/navigator.dart';
import '../../../profile/details/index.dart';
import '../index.dart';
import 'searched_accounts_item.dart';
import 'searched_auctions_item.dart';

class RecentSearchItemWidget extends StatelessWidget {
  final BuildContext ctx;
  final SearchHistoryItem item;
  final navigationService = Get.find<NavigatorService>();

  RecentSearchItemWidget({
    super.key,
    required this.ctx,
    required this.item,
  });

  Widget _renderSearchItem(SearchHistoryItem userSearch) {
    switch (userSearch.type) {
      case SearchHistoryItemType.account:
        return _renderAccountSearch(userSearch);
      case SearchHistoryItemType.search:
        return _renderSimpleSearch(userSearch);
      case SearchHistoryItemType.auction:
        return _renderAuctionSearch(userSearch);
    }
  }

  Widget _renderSimpleSearch(SearchHistoryItem searchItem) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showSearch(
            context: ctx,
            delegate: SearchScreen(),
            query: searchItem.searchKey,
          );
        },
        child: Row(children: [
          Container(width: 16),
          SizedBox(
            width: 35,
            height: 46,
            child: SvgPicture.asset(
              'assets/icons/svg/history.svg',
              height: 30,
              semanticsLabel: 'Search history item',
              colorFilter: ColorFilter.mode(
                Theme.of(ctx).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
          ),
          Container(width: 16),
          Flexible(
            child: Text(
              searchItem.searchKey,
              style: Theme.of(ctx).extension<CustomThemeFields>()!.smaller,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _renderAuctionSearch(SearchHistoryItem searchItem) {
    var auction = jsonDecode(searchItem.data ?? '');
    if (auction != '') {
      try {
        var auctionData = Auction.fromJSON(auction);

        return SearchedAuctionsSuggestionItem(
          auction: auctionData,
          ctx: ctx,
          onTap: () {
            navigationService.push(
              AuctionDetailsScreen(
                auctionId: auctionData.id,
                assetsLen: auctionData.assets?.length ?? 1,
              ),
              NavigationStyle.SharedAxis,
            );
          },
        );
      } catch (err, stack) {
        print('Error: $err');
        print('Stack: $stack');
      }
    }

    return Text(
      searchItem.searchKey,
      style: Theme.of(ctx).extension<CustomThemeFields>()!.smaller,
    );
  }

  Widget _renderAccountSearch(SearchHistoryItem searchItem) {
    var account = jsonDecode(searchItem.data ?? '');
    if (account != '') {
      var accountData = Account.fromJSON(account);

      return SearchedAccountsSuggestionItem(
        account: accountData,
        ctx: ctx,
        onTap: () {
          navigationService.push(
            ProfileDetailsScreen(
              accountId: accountData.id,
            ),
            NavigationStyle.SharedAxis,
          );
        },
      );
    }

    return Text(
      searchItem.searchKey,
      style: Theme.of(ctx).extension<CustomThemeFields>()!.smaller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _renderSearchItem(item);
  }
}
