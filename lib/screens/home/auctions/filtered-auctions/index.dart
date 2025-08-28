import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/filter.dart';
import '../../../../core/controllers/main.dart';
import '../../../../core/models/auction.dart';
import '../../../../core/repositories/auction.dart';
import '../../../../widgets/auction-card/index.dart';
import '../../../../widgets/common/banner_ad.dart';
import '../../../../widgets/common/no_internet_connection.dart';
import '../../../../widgets/no_data.dart';
import '../../../../widgets/shimmers/auctions_list.dart';
import 'app_bar.dart';

class FilteredAuctionsScreen extends StatefulWidget {
  const FilteredAuctionsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FilteredAuctionsScreen createState() => _FilteredAuctionsScreen();
}

class _FilteredAuctionsScreen extends State<FilteredAuctionsScreen> {
  final mainController = Get.find<MainController>();
  final filterController = Get.find<FilterController>();

  var _loading = false;
  var _reloadingAllAuctions = false;
  var _initialLoading = false;
  final List<Rx<Auction>> _auctions = [];

  late int _pageNumber;
  late bool _isLastPage;
  static const _pageSize = 20;
  AuctionsSortBy? _sortBy;

  @override
  void initState() {
    super.initState();

    _pageNumber = 0;
    _isLastPage = false;
    fetchData(true);
  }

  Future<void> fetchData([bool isInitialLoading = false]) async {
    if (_loading || _isLastPage || _reloadingAllAuctions) {
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

      var newItemsFunct = filterController.loadFilteredAuctions(
        _pageNumber,
        _pageSize,
        _sortBy,
      );

      final newItems = await newItemsFunct;

      if (mounted) {
        setState(() {
          _isLastPage = newItems.length < _pageSize;
          _loading = false;
          _pageNumber = _pageNumber + 1;
          _auctions.addAll(newItems.map((e) => e.obs));
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

  Future<void> handleSortChange(AuctionsSortBy? sortBy) async {
    if (_loading) {
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _loading = true;
          _pageNumber = 0;
          _isLastPage = false;
          _sortBy = sortBy;
          _auctions.clear();
        });
      }

      var newItemsFunct = filterController.loadFilteredAuctions(
        _pageNumber,
        _pageSize,
        sortBy,
      );

      final newItems = await newItemsFunct;
      if (mounted) {
        setState(() {
          _isLastPage = newItems.length < _pageSize;
          _loading = false;
          _pageNumber = _pageNumber + 1;
          _auctions.addAll(newItems.map((e) => e.obs));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> handleFilterUpdate() async {
    if (_loading || _reloadingAllAuctions) {
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _reloadingAllAuctions = true;
          _pageNumber = 0;
          _isLastPage = false;
          _auctions.clear();
        });
      }

      final newItems = await filterController.loadFilteredAuctions(
        _pageNumber,
        _pageSize,
        _sortBy,
      );

      if (mounted) {
        setState(() {
          _isLastPage = newItems.length < _pageSize;
          _reloadingAllAuctions = false;
          _pageNumber = _pageNumber + 1;
          _auctions.addAll(newItems.map((e) => e.obs));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reloadingAllAuctions = false;
        });
      }
    }
  }

  Widget _renderAuctionsList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

          if (index > 1 && index % 8 == 0) {
            return Column(
              children: [
                BannerAdCard(
                  marginTop: 0,
                  marginBottom: 8,
                ),
                SizedBox(
                  child: AuctionCard(
                    auction: _auctions[index],
                  ),
                )
              ],
            );
          }

          if (index > 1 && (index - 1) % 8 == 0) {
            return Column(
              children: [
                BannerAdCard(
                  marginTop: 0,
                  marginBottom: 8,
                ),
                SizedBox(
                  child: AuctionCard(
                    auction: _auctions[index],
                  ),
                )
              ],
            );
          }

          return SizedBox(
            child: AuctionCard(
              auction: _auctions[index],
            ),
          );
        },
      ),
    );
  }

  Widget _renderBody() {
    if (_reloadingAllAuctions) {
      return SizedBox(
        height: Get.height,
        width: double.infinity,
        child: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color:
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
            ),
          ),
        ),
      );
    }

    return Material(
      child: Container(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        width: Get.width,
        constraints: BoxConstraints(
          minHeight: Get.height,
        ),
        child: Obx(
          () => mainController.connectivity.contains(ConnectivityResult.none)
              ? const NoInternetConnectionScreen()
              : _initialLoading
                  ? AuctionsListShimmer(
                      auctionsCount:
                          filterController.filteredAuctionsCount.value,
                    )
                  : _auctions.isNotEmpty || _loading
                      ? _renderAuctionsList()
                      : NoDataMessage(
                          message: tr('home.auctions.no_auctions_to_display'),
                        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FilteredAuctionsAppBar(
        onSort: (AuctionsSortBy? sortBy) {
          EasyDebounce.debounce(
            'sort-filtered-auctions',
            const Duration(milliseconds: 300),
            () => handleSortChange(sortBy),
          );
        },
        onScrollBottom: () {
          fetchData();
        },
        onFilterUpdate: () {
          handleFilterUpdate();
        },
        child: _renderBody(),
      ),
    );
  }
}
