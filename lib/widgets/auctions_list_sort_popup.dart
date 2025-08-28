import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../core/repositories/auction.dart';
import 'common/popup_selected_item_bullet.dart';

class AuctionsListSortPopup extends StatefulWidget {
  final AuctionsSortBy? sortBy;
  final Function? handleSort;

  const AuctionsListSortPopup({
    super.key,
    this.sortBy = AuctionsSortBy.newest,
    this.handleSort,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionsListSortPopup createState() => _AuctionsListSortPopup();
}

class _AuctionsListSortPopup extends State<AuctionsListSortPopup> {
  late AuctionsSortBy sortBy;

  @override
  void initState() {
    super.initState();
    sortBy = widget.sortBy ?? AuctionsSortBy.newest;
  }

  handleSearch(AuctionsSortBy newSortBy) {
    if (newSortBy == sortBy) {
      return;
    }
    if (mounted) {
      setState(() {
        sortBy = newSortBy;
      });
    }

    if (widget.handleSort != null) {
      widget.handleSort!(newSortBy);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(29)),
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              'assets/icons/svg/sort.svg',
              height: 28,
              semanticsLabel: 'Sort',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              onTap: () {
                handleSearch(AuctionsSortBy.newest);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/hourglass-top.svg',
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                        semanticsLabel: 'Newest',
                      ),
                      Container(
                        width: 8,
                      ),
                      Text(
                        'generic.newest',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ],
                  ),
                  sortBy == AuctionsSortBy.newest
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                handleSearch(AuctionsSortBy.oldest);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/hourglass-bottom.svg',
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                        semanticsLabel: 'Oldest',
                      ),
                      Container(
                        width: 8,
                      ),
                      Text(
                        'generic.oldest',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ],
                  ),
                  sortBy == AuctionsSortBy.oldest
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                handleSearch(AuctionsSortBy.priceAsc);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/sort-ascending.svg',
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                        semanticsLabel: 'Price ascending',
                      ),
                      Container(
                        width: 8,
                      ),
                      Text(
                        'generic.ascending_price',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ],
                  ),
                  sortBy == AuctionsSortBy.priceAsc
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                handleSearch(AuctionsSortBy.priceDesc);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/sort-descending.svg',
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                        semanticsLabel: 'Price descending',
                      ),
                      Container(
                        width: 8,
                      ),
                      Text(
                        'generic.descending_price',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ],
                  ),
                  sortBy == AuctionsSortBy.priceDesc
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
