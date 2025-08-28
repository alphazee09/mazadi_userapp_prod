import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';

import '../../../core/models/auction.dart';
import '../../../core/models/review.dart';
import '../../../core/navigator.dart';
import '../../../utils/generic.dart';
import '../../../widgets/common/user_avatar.dart';
import '../../profile/details/index.dart';

class AuctionReview extends StatelessWidget {
  final navigatorService = Get.find<NavigatorService>();

  final Rx<Auction> auction;
  final Review? review;

  AuctionReview({
    super.key,
    required this.auction,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    if (review == null) {
      return Container();
    }

    var addedReviewMsg = tr('auction_details.reviews.added_a_review');
    var noDescriptionMsg = tr('auction_details.no_description_provided');

    var seeLess = tr("generic.see_less");
    var seeMore = tr("generic.see_more");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context)
              .extension<CustomThemeFields>()!
              .separator
              .withOpacity(0.3),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              UserAvatar(
                account: review!.reviewer,
                small: true,
                size: 40,
              ),
              Container(
                width: 8,
              ),
              Flexible(
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: GenericUtils.generateNameForAccount(
                          review!.reviewer,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (review?.reviewer?.id == null) {
                              return;
                            }

                            navigatorService.push(
                              ProfileDetailsScreen(
                                accountId: review!.reviewer!.id,
                              ),
                              NavigationStyle.SharedAxis,
                            );
                          },
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller
                            .copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextSpan(
                        text: addedReviewMsg,
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 16,
          ),
          RatingBar(
            initialRating: review!.stars.toDouble(),
            minRating: review!.stars.toDouble(),
            maxRating: review!.stars.toDouble(),
            itemCount: 5,
            ignoreGestures: true,
            itemSize: 32,
            ratingWidget: RatingWidget(
              full: SvgPicture.asset(
                'assets/icons/svg/star-filled.svg',
                semanticsLabel: 'Star',
                colorFilter: ColorFilter.mode(
                  Colors.amber,
                  BlendMode.srcIn,
                ),
              ),
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
            height: 8,
          ),
          ReadMoreText(
            review!.description == null || review!.description!.isEmpty
                ? noDescriptionMsg
                : review!.description!,
            trimLines: 2,
            trimLength: 100,
            textAlign: TextAlign.left,
            style: Theme.of(context).extension<CustomThemeFields>()!.subtitle,
            trimExpandedText: seeLess,
            trimCollapsedText: seeMore,
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
          ),
          Container(
            height: 16,
          ),
        ]),
      ),
    );
  }
}
