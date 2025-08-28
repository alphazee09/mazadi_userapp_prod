import 'dart:convert';

import 'package:mazadi/widgets/common/section_heading.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/models/account.dart';
import '../../../../core/models/search_history_item.dart';
import '../../../../core/navigator.dart';
import '../../../profile/details/index.dart';
import '../../../../core/controllers/search.dart' as search_ctrl;
import 'searched_accounts_item.dart';

// ignore: must_be_immutable
class SearchedAccounts extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();
  final searchController = Get.find<search_ctrl.SearchController>();

  List<Account> accounts;
  String userQuery;
  BuildContext ctx;

  SearchedAccounts({
    required this.accounts,
    required this.userQuery,
    required this.ctx,
  });

  Widget _renderNoAccountsFound() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'home.search.no_users_that_match',
              style: Theme.of(ctx).extension<CustomThemeFields>()!.smaller,
              textAlign: TextAlign.center,
            ).tr(),
          ),
        ],
      ),
    );
  }

  Widget _renderSuggestionItem(Account account) {
    return SearchedAccountsSuggestionItem(
      account: account,
      ctx: ctx,
      onTap: () {
        searchController.addSearchHistoryItem(
          SearchHistoryItemType.account,
          userQuery,
          jsonEncode(account),
          account.id,
        );

        navigatorService.push(
          ProfileDetailsScreen(
            accountId: account.id,
          ),
          NavigationStyle.SharedAxis,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8,
        ),
        SectionHeading(
          title: tr('home.search.users'),
          ctx: ctx,
          withMore: accounts.isNotEmpty && accounts.length > 5,
        ),
        accounts.isEmpty ? _renderNoAccountsFound() : Container(),
        for (var account in accounts.take(5)) _renderSuggestionItem(account)
      ],
    );
  }
}
