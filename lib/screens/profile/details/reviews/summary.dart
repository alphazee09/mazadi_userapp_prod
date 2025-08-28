import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/account.dart';
import '../../../../core/models/review.dart';
import '../../../../core/navigator.dart';
import '../../../../utils/generic.dart';
import '../../../../widgets/common/section_heading.dart';
import '../../../../widgets/common/simple_button.dart';
import 'review_item.dart';
import 'reviews_list.dart';

// ignore: must_be_immutable
class AccountReviewsSummary extends StatelessWidget {
  final List<Review> reviews;
  final double? reviewsAverage;
  final int count;
  final String accountId;

  AccountReviewsSummary({
    super.key,
    this.reviewsAverage,
    required this.reviews,
    required this.count,
    required this.accountId,
  });

  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: tr('profile.reviews.reviews'),
            titleSufix: '(${count.toString()})',
            withMore: false,
            sufix: reviews.isNotEmpty
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          reviewsAverage != null
                              ? reviewsAverage!.toStringAsFixed(2)
                              : GenericUtils.computeReviewsAverage(reviews)
                                  .toStringAsFixed(2),
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.only(start: 8, bottom: 2),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/svg/star-filled.svg',
                            semanticsLabel: 'Star',
                            colorFilter: ColorFilter.mode(
                              Colors.amber,
                              BlendMode.srcIn,
                            ),
                            height: 16,
                            width: 16,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
            onPressed: () {
              navigatorService.push(
                AccountReviewsList(
                  accountId: accountId,
                  reviewsCount: count,
                ),
                NavigationStyle.SharedAxis,
              );
            },
          ),
          reviews.isNotEmpty
              ? Container()
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    accountId != accountController.account.value.id
                        ? 'profile.reviews.no_reviews'
                        : 'profile.reviews.no_reviews_for_you',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                    textAlign: TextAlign.start,
                  ).tr(),
                ),
          Column(
            children: [for (var review in reviews) ReviewItem(review: review)],
          ),
          count > 0
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 40,
                      child: IntrinsicWidth(
                        child: SimpleButton(
                          onPressed: () {
                            navigatorService.push(
                              AccountReviewsList(
                                accountId: accountId,
                                reviewsCount: count,
                              ),
                              NavigationStyle.SharedAxis,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'profile.reviews.see_all_reviews',
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller,
                            ).tr(namedArgs: {'no': count.toString()}),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
