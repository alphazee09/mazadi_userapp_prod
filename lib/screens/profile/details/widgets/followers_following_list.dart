import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/controllers/followers.dart';
import '../../../../core/models/account.dart';
import '../../../../core/navigator.dart';
import '../../../../utils/generic.dart';
import '../../../../widgets/common/user_avatar.dart';
import '../../../../widgets/no_data.dart';
import '../index.dart';

class AccountFollowersOrFollowingList extends StatefulWidget {
  final Account account;
  final bool isFollowing;

  const AccountFollowersOrFollowingList({
    super.key,
    required this.account,
    this.isFollowing = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AccountFollowersOrFollowingListState createState() =>
      _AccountFollowersOrFollowingListState();
}

class _AccountFollowersOrFollowingListState
    extends State<AccountFollowersOrFollowingList> {
  final followersController = Get.find<FollowersController>();
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
      var accountsList = widget.isFollowing
          ? await followersController.getFollowing(
              widget.account.id,
              page,
              _pageSize,
            )
          : await followersController.getFollowers(
              widget.account.id,
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
                      widget.isFollowing
                          ? 'profile.following'
                          : 'profile.followers',
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
                        widget.isFollowing
                            ? 'profile.no_following'
                            : 'profile.no_followers',
                        namedArgs: {
                          'name': GenericUtils.generateNameForAccount(
                            widget.account,
                          ),
                        }),
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
