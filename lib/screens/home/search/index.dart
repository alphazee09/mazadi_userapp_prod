import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:debounce_throttle/debounce_throttle.dart';

import '../../../core/models/account.dart';
import '../../../core/models/auction.dart';
import '../../../core/models/search_history_item.dart';
import '../../../core/controllers/search.dart' as search_ctrl;
import 'widgets/recent_searches.dart';
import 'widgets/searched_accounts.dart';
import 'widgets/searched_auctions.dart';

class SearchScreen extends SearchDelegate<String> {
  final searchController = Get.find<search_ctrl.SearchController>();

  dynamic currentSearchResult;
  late String userQuery;

  final debouncer = Debouncer<String>(
    const Duration(milliseconds: 500),
    initialValue: '',
  );

  void addStringSearchHistoryItem(String query) {
    searchController.addSearchHistoryItem(SearchHistoryItemType.search, query);
  }

  Future<dynamic> queryChanged(String query) async {
    if (query == debouncer.value) {
      return currentSearchResult;
    }

    debouncer.value = userQuery = query;
    await debouncer.nextValue;

    if (query != userQuery) {
      return currentSearchResult;
    }

    currentSearchResult = await searchController.triggerSuggestionsBuild(query);
    return currentSearchResult;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    var theme = Theme.of(context);

    return theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        hintStyle: Theme.of(context).extension<CustomThemeFields>()!.subtitle,
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: Theme.of(context).extension<CustomThemeFields>()!.subtitle,
      ),
      appBarTheme: theme.appBarTheme.copyWith(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
      ),
    );
  }

  @override
  String get searchFieldLabel => tr('home.search.search');

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query == '') {
      return [Container()];
    }

    return [
      Container(
        width: 50,
        alignment: Alignment.centerRight,
        margin: const EdgeInsetsDirectional.only(end: 16),
        child: IconButton(
          splashRadius: 24,
          icon: SvgPicture.asset(
            'assets/icons/svg/close.svg',
            semanticsLabel: 'Close',
            height: 16,
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16),
      child: Transform.rotate(
        angle: 180 * math.pi / 180,
        child: IconButton(
          splashRadius: 24,
          icon: SvgPicture.asset(
            'assets/icons/svg/next.svg',
            semanticsLabel: 'Next',
            height: 16,
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            close(context, query);
          },
        ),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    addStringSearchHistoryItem(query);
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      height: Get.height,
      color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
      child: SingleChildScrollView(
        child: query == ''
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RecentSearches(
                    ctx: context,
                    theme: Theme.of(context),
                    background: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_1,
                  ),
                ],
              )
            : FutureBuilder(
                future: queryChanged(query),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Account> accounts = snapshot.data[0].toList();
                    List<Auction> auctions = snapshot.data[1].toList();

                    return Container(
                      width: Get.width,
                      constraints: BoxConstraints(minHeight: Get.height),
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .background_1,
                      child: Column(
                        children: [
                          Container(
                            height: 16,
                          ),
                          SearchedAccounts(
                            accounts: accounts,
                            userQuery: query,
                            ctx: context,
                          ),
                          Container(
                            height: 16,
                          ),
                          SearchedAuctions(
                            auctions: auctions,
                            userQuery: query,
                            ctx: context,
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.only(top: 32),
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
      ),
    );
  }
}
