import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/models/account.dart';
import '../../../../core/models/auction.dart';
import '../../../../core/navigator.dart';
import '../../../../widgets/auction-card/index.dart';
import '../../../../widgets/common/section_heading.dart';
import '../all-auctions/index.dart';

class AccountAuctions extends StatelessWidget {
  final int? auctionsCount;
  final Account account;
  final List<Auction>? auctions;
  final String? title;
  final bool? withSeeMore;
  final bool? withTitleSufix;

  final navigationService = Get.find<NavigatorService>();

  AccountAuctions({
    super.key,
    this.auctionsCount,
    required this.account,
    required this.auctions,
    this.title,
    this.withSeeMore = true,
    this.withTitleSufix = true,
  });

  Widget _renderAuctionsList(BuildContext context, List<Auction> auctionsList) {
    return auctionsList.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                ),
                for (var auction in auctionsList)
                  Container(
                    margin: const EdgeInsetsDirectional.only(end: 12),
                    width: 170,
                    child: AuctionCard(
                      auction: auction.obs,
                    ),
                  )
              ],
            ),
          )
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'profile.no_auctions',
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
              textAlign: TextAlign.start,
            ).tr(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: title ?? tr('home.auctions.auctions'),
            titleSufix: withTitleSufix == true
                ? '(${auctionsCount ?? auctions?.length ?? 0})'
                : null,
            withMore: withSeeMore ?? true,
            onPressed: () {
              navigationService.push(
                AllAccountAuctionsScreen(
                  auctionsCount: auctionsCount ?? auctions?.length ?? 0,
                  account: account,
                ),
                NavigationStyle.SharedAxis,
              );
            },
          ),
          auctions != null
              ? _renderAuctionsList(context, auctions!)
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('profile.no_auctions',
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller)
                      .tr(),
                ),
        ],
      ),
    );
  }
}
