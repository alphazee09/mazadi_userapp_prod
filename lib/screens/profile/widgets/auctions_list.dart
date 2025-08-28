import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masonry_grid/masonry_grid.dart';

import '../../../core/controllers/auction.dart';
import '../../../core/controllers/main.dart';
import '../../../core/models/auction.dart';
import '../../../core/repositories/auction.dart';
import '../../../widgets/auction-card/index.dart';
import '../../../widgets/auctions_list_sort_popup.dart';
import '../../../widgets/no_data.dart';
import '../../../widgets/shimmers/auctions_list.dart';
import '../../../widgets/simple_app_bar.dart';

class ProfileAuctionsListByStatus extends StatefulWidget {
  final String status;
  final Widget title;
  final int initialAuctionsCount;
  final String noAuctionsMessage;

  final Function? sortWidget;

  const ProfileAuctionsListByStatus({
    super.key,
    this.sortWidget,
    required this.status,
    required this.title,
    required this.initialAuctionsCount,
    required this.noAuctionsMessage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfileAuctionsSettingsScreen createState() =>
      _ProfileAuctionsSettingsScreen();
}

class _ProfileAuctionsSettingsScreen
    extends State<ProfileAuctionsListByStatus> {
  final mainController = Get.find<MainController>();
  final auctionsController = Get.find<AuctionController>();

  var _loading = false;
  var _initialLoading = false;

  final Rx<bool> _pointerDownInner = false.obs;
  final List<Rx<Auction>> _auctions = [];

  late int _pageNumber;
  late bool _isLastPage;
  String _query = '';
  AuctionsSortBy? _sortBy;
  static const _pageSize = 20;

  @override
  void initState() {
    _pageNumber = 0;
    _isLastPage = false;
    fetchData(true);
    super.initState();
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

      var newItemsFunct = auctionsController.loadForAccount(
        widget.status,
        _pageNumber,
        _pageSize,
        _query,
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

  Future<void> handleQueryChange(String query) async {
    if (_loading || _query == query) {
      return;
    }

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _query = '';
          _pageNumber = 0;
          _isLastPage = false;
          _auctions.clear();
        });
      }
      fetchData();
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _loading = true;
          _query = query;
          _pageNumber = 0;
          _isLastPage = false;
          _auctions.clear();
        });
      }

      var newItemsFunct = auctionsController.loadForAccount(
        widget.status,
        _pageNumber,
        _pageSize,
        _query,
        _sortBy,
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

      var newItemsFunct = auctionsController.loadForAccount(
        widget.status,
        _pageNumber,
        _pageSize,
        _query,
        _sortBy,
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
              fetchData();
            }
            return true;
          },
          // if you used network it would good to use the stream or future builder
          child: Scaffold(
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            resizeToAvoidBottomInset: true,
            appBar: SimpleAppBar(
                onBack: goBack,
                withSearch: true,
                handleSearchInputTapDown: () {
                  _pointerDownInner.value = true;
                },
                withClearSearchKey: true,
                isLoading: _loading || _initialLoading,
                handleSearch: (key) {
                  EasyDebounce.debounce(
                    'search-${widget.status}-auctions',
                    const Duration(milliseconds: 300),
                    () => handleQueryChange(key),
                  );
                },
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(
                            child: widget.title,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsetsDirectional.only(end: 16),
                      child: Row(
                        children: [
                          widget.sortWidget != null
                              ? widget.sortWidget!((AuctionsSortBy? sortBy) {
                                  EasyDebounce.debounce(
                                    'sort-${widget.status}-auctions',
                                    const Duration(milliseconds: 300),
                                    () => handleSortChange(sortBy),
                                  );
                                })
                              : AuctionsListSortPopup(
                                  handleSort: (AuctionsSortBy? sortBy) {
                                    EasyDebounce.debounce(
                                      'sort-${widget.status}-auctions',
                                      const Duration(milliseconds: 300),
                                      () => handleSortChange(sortBy),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                )),
            body: _initialLoading && widget.initialAuctionsCount != 0
                ? AuctionsListShimmer(
                    auctionsCount: widget.initialAuctionsCount,
                  )
                : (_auctions.isEmpty && !_loading)
                    ? NoDataMessage(
                        message: _query.length > 1
                            ? tr('home.auctions.no_auctions_to_match_criteria')
                            : widget.noAuctionsMessage,
                      )
                    : SingleChildScrollView(
                        child: Container(
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .background_1,
                          width: Get.width,
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: MasonryGrid(
                                  column: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  children: [
                                    for (var auction in _auctions)
                                      AuctionCard(
                                        auction: auction,
                                      )
                                  ],
                                ),
                              ),
                              _loading
                                  ? SizedBox(
                                      height: 100,
                                      width: Get.width,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: IntrinsicHeight(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Theme.of(context)
                                                    .extension<
                                                        CustomThemeFields>()!
                                                    .fontColor_1,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}
