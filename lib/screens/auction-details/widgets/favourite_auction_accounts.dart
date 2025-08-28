import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../core/controllers/favourites.dart';
import '../../../core/models/account.dart';
import '../../../core/navigator.dart';
import '../../../theme/extensions/base.dart';
import '../../../utils/generic.dart';
import '../../../widgets/common/user_avatar.dart';
import '../../../widgets/no_data.dart';
import '../../profile/details/index.dart';

class AuctionsWhoAddedAuctionAsFavouriteList extends StatefulWidget {
  final String auctionId;

  const AuctionsWhoAddedAuctionAsFavouriteList({
    super.key,
    required this.auctionId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionsWhoAddedAuctionAsFavouriteListState createState() =>
      _AuctionsWhoAddedAuctionAsFavouriteListState();
}

class _AuctionsWhoAddedAuctionAsFavouriteListState
    extends State<AuctionsWhoAddedAuctionAsFavouriteList> {
  final favouritesController = Get.find<FavouritesController>();
  final navigatorService = Get.find<NavigatorService>();

  final PagingController<int, Widget> _pagingController =
      PagingController(firstPageKey: 0);

  static const _pageSize = 20;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchData(pageKey);
    });

    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchData(int page) async {
    try {
      var accountsList =
          await favouritesController.loadAccountsThatHaveAuctionInFavourites(
        widget.auctionId,
        page,
        _pageSize,
      );

      final isLastPage = accountsList.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(_computeListItems(accountsList));
      } else {
        final nextPageKey = page + 1;
        _pagingController.appendPage(
            _computeListItems(accountsList), nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  List<Widget> _computeListItems(List<Account> accountsWhoAnswered) {
    return [
      for (var account in accountsWhoAnswered)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              navigatorService.push(
                ProfileDetailsScreen(
                  accountId: account.id,
                ),
                NavigationStyle.SharedAxis,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .separator
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .separator,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        UserAvatar(
                          account: account,
                          small: true,
                        ),
                        Container(
                          width: 8,
                        ),
                        Flexible(
                          child: Text(
                            GenericUtils.generateNameForAccount(account),
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'favourites.users_who_added_to_favourites',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title,
                    ).tr(),
                  ),
                  IconButton(
                    splashRadius: 24,
                    iconSize: 14,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/svg/close.svg',
                      semanticsLabel: 'Close',
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 16,
            ),
            Expanded(
              child: PagedListView(
                scrollDirection: Axis.vertical,
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate(
                  noItemsFoundIndicatorBuilder: (_) => NoDataMessage(
                    message: tr(
                      'favourites.nobody_added_to_favourites',
                    ),
                  ),
                  itemBuilder: (context, item, index) {
                    return item as Widget;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
