import 'package:mazadi/core/controllers/auction.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/last_seen_auctions.dart';
import '../../../../core/controllers/main.dart';
import '../../../../core/models/auction.dart';
import '../../../../widgets/auction-card/index.dart';
import '../../../../widgets/common/no_internet_connection.dart';
import '../../../../widgets/no_data.dart';
import '../../../../widgets/shimmers/auctions_list.dart';
import '../../../../widgets/simple_app_bar.dart';

class LastSeenAuctionScreen extends StatefulWidget {
  const LastSeenAuctionScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LastSeenAuctionScreen createState() => _LastSeenAuctionScreen();
}

class _LastSeenAuctionScreen extends State<LastSeenAuctionScreen> {
  final auctionsController = Get.find<AuctionController>();
  final lastSeenAuctionController = Get.find<LastSeenAuctionsController>();
  final mainController = Get.find<MainController>();

  final List<Rx<Auction>> _auctions = [];
  var _loading = false;
  var _initialLoading = false;

  late int _pageNumber;
  late bool _isLastPage;
  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _pageNumber = 0;
    _isLastPage = false;
    fetchData(true);
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  Future<void> fetchData([bool isInitialLoading = false]) async {
    if (_loading || _isLastPage) {
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _loading = true;

          if (isInitialLoading) {
            _initialLoading = true;
          }
        });
      }

      var newItemsFunct = lastSeenAuctionController.loadByPage(
        _pageNumber,
        _pageSize,
      );

      final newItems = await newItemsFunct;
      if (mounted) {
        setState(() {
          _isLastPage = newItems.length < _pageSize;
          _loading = false;
          _pageNumber = _pageNumber + 1;
          _auctions.addAll(newItems.map((e) => e));
          if (isInitialLoading) {
            _initialLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          if (isInitialLoading) {
            _initialLoading = false;
          }
        });
      }
    }
  }

  Widget _renderContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: MasonryGridView.count(
        itemCount: _auctions.length + 1,
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemBuilder: (context, index) {
          if (index == _auctions.length) {
            return _loading
                ? SizedBox(
                    height: 100,
                    width: Get.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: IntrinsicHeight(
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .fontColor_1,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container();
          }
          return SizedBox(
            child: AuctionCard(
              auction: _auctions[index],
              ignoreUpdateOnClose: true,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          var nextPageTrigger = 0.8 * scrollInfo.metrics.maxScrollExtent;
          if (scrollInfo.metrics.pixels > nextPageTrigger) {
            fetchData();
          }
          return true;
        },
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          resizeToAvoidBottomInset: true,
          appBar: SimpleAppBar(
            onBack: () {
              goBack();
            },
            withSearch: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'home.auctions.last_seen',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ).tr(),
                ),
              ],
            ),
          ),
          body: Obx(
            () => mainController.connectivity.contains(ConnectivityResult.none)
                ? const NoInternetConnectionScreen()
                : _initialLoading
                    ? AuctionsListShimmer(
                        auctionsCount:
                            auctionsController.allActiveAuctionsCount.value,
                      )
                    : _auctions.isNotEmpty || _loading
                        ? _renderContent()
                        : NoDataMessage(
                            message: tr('home.auctions.no_auctions_to_display'),
                          ),
          ),
        ),
      ),
    );
  }
}
