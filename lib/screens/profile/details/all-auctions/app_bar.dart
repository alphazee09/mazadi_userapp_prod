import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/main.dart';
import '../../../../core/models/account.dart';
import '../../../../utils/generic.dart';
import '../../../../widgets/auctions_list_sort_popup.dart';
import '../../../../widgets/simple_app_bar.dart';

class AccountAllAuctionsAppBar extends StatefulWidget {
  final int auctionsCount;
  final Account account;

  final Widget child;
  final bool? loadingData;
  final Function? onScrollBottom;
  final Function? onSearchKeyUpdate;
  final Function? onSort;

  const AccountAllAuctionsAppBar({
    super.key,
    required this.child,
    this.loadingData,
    this.onScrollBottom,
    this.onSearchKeyUpdate,
    this.onSort,
    required this.auctionsCount,
    required this.account,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FilteredAuctionsSimpleAppBar createState() =>
      _FilteredAuctionsSimpleAppBar();
}

class _FilteredAuctionsSimpleAppBar extends State<AccountAllAuctionsAppBar> {
  final mainController = Get.find<MainController>();
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
              onBack: () {
                goBack();
              },
              handleSearchInputTapDown: () {
                _pointerDownInner.value = true;
              },
              isLoading: widget.loadingData ?? false,
              withClearSearchKey: true,
              withSearch: true,
              handleSearch: (String key) {
                if (widget.onSearchKeyUpdate != null) {
                  widget.onSearchKeyUpdate!(key);
                }
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
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'profile.all_auctions_for',
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .title,
                              ).tr(namedArgs: {
                                'no': widget.auctionsCount.toString(),
                                'name': GenericUtils.generateNameForAccount(
                                    widget.account),
                              }),
                            ),
                          ],
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
