import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/controllers/account.dart';
import '../../../../core/controllers/review.dart';
import '../../../../core/models/review.dart';
import '../../../../widgets/no_data.dart';
import '../../../../widgets/simple_app_bar.dart';
import 'review_item.dart';

class AccountReviewsList extends StatefulWidget {
  final String accountId;
  final int? reviewsCount;

  const AccountReviewsList({
    super.key,
    required this.accountId,
    this.reviewsCount,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AccountReviewsListState createState() => _AccountReviewsListState();
}

class _AccountReviewsListState extends State<AccountReviewsList> {
  final accountController = Get.find<AccountController>();
  final reviewsController = Get.find<ReviewsController>();

  var _loading = false;
  static const _pageSize = 15;

  final PagingController<int, ReviewItem> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(0);

      _pagingController.addPageRequestListener((pageKey) {
        _fetchData(pageKey);
      });
    });

    super.initState();
  }

  Future<void> _fetchData(int page) async {
    try {
      if (mounted) {
        setState(() {
          _loading = true;
        });
      }

      var impressionsList = await reviewsController.loadForAccount(
        widget.accountId,
        page,
        _pageSize,
      );

      final isLastPage = impressionsList.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(_computeListItems(impressionsList));
      } else {
        final nextPageKey = page + 1;
        _pagingController.appendPage(
            _computeListItems(impressionsList), nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  List<ReviewItem> _computeListItems(List<Review> reviews) {
    return [
      for (var review in reviews) ReviewItem(review: review),
    ];
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: true,
        appBar: SimpleAppBar(
            onBack: () => goBack(context),
            withSearch: false,
            isLoading: _loading,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'profile.reviews.reviews',
                    textAlign: TextAlign.start,
                    style:
                        Theme.of(context).extension<CustomThemeFields>()!.title,
                  ).tr(),
                ),
                widget.reviewsCount != null
                    ? Flexible(
                        child: Text(
                          ' (${widget.reviewsCount})',
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .title,
                        ),
                      )
                    : Container(),
              ],
            )),
        body: PagedListView(
          scrollDirection: Axis.vertical,
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate(
            noItemsFoundIndicatorBuilder: (_) => NoDataMessage(
              message: tr(
                'profile.reviews.no_reviews_for_account',
              ),
            ),
            itemBuilder: (context, item, index) {
              return item as Widget;
            },
          ),
        ),
      ),
    );
  }
}
