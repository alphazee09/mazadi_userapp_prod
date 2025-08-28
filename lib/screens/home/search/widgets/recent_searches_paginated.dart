import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/models/search_history_item.dart';
import '../../../../widgets/no_data.dart';
import '../../../../core/controllers/search.dart' as tanna_search;
import '../../../../widgets/simple_app_bar.dart';
import 'recent_search_item.dart';

class RecentSearchesPaginated extends StatefulWidget {
  final List<SearchHistoryItem> historyItems;
  final BuildContext ctx;

  const RecentSearchesPaginated({
    super.key,
    required this.historyItems,
    required this.ctx,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SearchBookSuggestionPaginatedList createState() =>
      _SearchBookSuggestionPaginatedList();
}

class _SearchBookSuggestionPaginatedList
    extends State<RecentSearchesPaginated> {
  final searchController = Get.find<tanna_search.SearchController>();
  final PagingController<int, RecentSearchItemWidget> _pagingController =
      PagingController(firstPageKey: 0);

  String _searchKey = '';
  static const _pageSize = 15;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchRecentSearches(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  List<RecentSearchItemWidget> _computeList(List<SearchHistoryItem> items) {
    return [
      for (var item in items)
        RecentSearchItemWidget(
          ctx: widget.ctx,
          item: item,
        )
    ];
  }

  Future<void> _fetchRecentSearches(int page) async {
    try {
      final newItems = await searchController.loadHistorySearches(
        _searchKey,
        page,
        _pageSize,
      );
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(_computeList(newItems));
      } else {
        final nextPageKey = page + 1;
        _pagingController.appendPage(_computeList(newItems), nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _search(String query) {
    if (mounted) {
      setState(() {
        _searchKey = query;
      });
    }
    _pagingController.refresh();
  }

  void goBack() {
    Navigator.of(widget.ctx).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(widget.ctx).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: true,
        appBar: SimpleAppBar(
          onBack: goBack,
          withSearch: true,
          withClearSearchKey: true,
          handleSearch: (String keyword) {
            EasyDebounce.debounce(
              'sort-recent-searches',
              const Duration(milliseconds: 300),
              () => _search(keyword),
            );
          },
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'home.search.recent_searches',
                textAlign: TextAlign.start,
                style:
                    Theme.of(widget.ctx).extension<CustomThemeFields>()!.title,
              ).tr()
            ],
          ),
        ),
        body: PagedListView(
          scrollDirection: Axis.vertical,
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) {
              return item as Widget;
            },
            noItemsFoundIndicatorBuilder: (_) => NoDataMessage(
              message: tr(
                'home.search.no_recent_search_found',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
