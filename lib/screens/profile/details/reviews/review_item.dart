import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';

import '../../../../core/models/review.dart';
import '../../../../core/navigator.dart';
import '../../../../utils/generic.dart';
import '../../../../widgets/common/user_avatar.dart';
import '../../../auction-details/index.dart';
import '../index.dart';

class ReviewItem extends StatelessWidget {
  final Review review;

  ReviewItem({
    super.key,
    required this.review,
  });

  final navigatorService = Get.find<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 8,
      ),
      padding: const EdgeInsets.all(8),
      width: Get.width,
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator),
        color: Theme.of(context)
            .extension<CustomThemeFields>()!
            .separator
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              navigatorService.push(
                ProfileDetailsScreen(
                  accountId: review.reviewer!.id,
                ),
                NavigationStyle.SharedAxis,
              );
            },
            child: Row(
              children: [
                UserAvatar(
                  account: review.reviewer!,
                  small: true,
                ),
                Container(
                  width: 16,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              GenericUtils.generateNameForAccount(
                                  review.reviewer!),
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller
                                  .copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      Container(
                        height: 4,
                      ),
                      Text(
                        DateFormat.yMMMd().format(review.createdAt),
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smallest,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 16,
          ),
          RatingBar(
            initialRating: review.stars.toDouble(),
            minRating: review.stars.toDouble(),
            maxRating: review.stars.toDouble(),
            itemCount: 5,
            itemSize: 16,
            ratingWidget: RatingWidget(
              full: SvgPicture.asset('assets/icons/svg/star-filled.svg',
                  semanticsLabel: 'Star',
                  colorFilter: ColorFilter.mode(
                    Colors.amber,
                    BlendMode.srcIn,
                  )),
              half: Container(),
              empty: SvgPicture.asset(
                'assets/icons/svg/star-filled.svg',
                semanticsLabel: 'Star',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
              ),
            ),
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            onRatingUpdate: (rating) {},
          ),
          Container(
            height: 16,
          ),
          review.description != null && review.description != ''
              ? ReadMoreText(
                  review.description!,
                  trimLines: 3,
                  trimLength: 200,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .subtitle,
                  trimExpandedText: tr('generic.see_less'),
                  trimCollapsedText: tr('generic.see_more'),
                  moreStyle: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                  lessStyle: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                )
              : Container(),
          Container(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ScaleTap(
                  onPressed: () {
                    if (review.auctionId != null) {
                      navigatorService.push(
                        AuctionDetailsScreen(
                          assetsLen: 0,
                          auctionId: review.auctionId!,
                        ),
                        NavigationStyle.SharedAxis,
                      );
                    }
                  },
                  child: Text(
                    'profile.see_review_auction',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller
                        .copyWith(
                          color: Colors.blue,
                        ),
                  ).tr(),
                ),
              ),
            ],
          ),
          Container(
            height: 8,
          ),
        ],
      ),
    );
  }
}
