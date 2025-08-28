import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/flash.dart';
import '../../../core/controllers/review.dart';
import '../../../core/models/account.dart';
import '../../../core/models/auction.dart';
import '../../../core/models/review.dart';
import '../../../core/navigator.dart';
import '../../../theme/colors.dart';
import '../../../utils/generic.dart';
import '../../../widgets/common/simple_button.dart';
import '../../profile/details/index.dart';

class AuctionReviewForm extends StatefulWidget {
  final Rx<Auction> auction;
  final Review? review;
  final Account leaveReviewFor;

  const AuctionReviewForm({
    super.key,
    required this.auction,
    required this.leaveReviewFor,
    this.review,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionReviewFormState createState() => _AuctionReviewFormState();
}

class _AuctionReviewFormState extends State<AuctionReviewForm> {
  final navigatorService = Get.find<NavigatorService>();
  final reviewController = Get.find<ReviewsController>();
  final flashController = Get.find<FlashController>();
  final _detailsController = TextEditingController();

  double _rating = 0;
  String _descriptionText = '';

  bool _reviewExisted = false;
  bool _updateInProgress = false;

  double _initialRating = 0;
  String _initialDescription = '';

  @override
  void initState() {
    super.initState();
    _rating = widget.review?.stars.toDouble() ?? 0;
    _initialRating = widget.review?.stars.toDouble() ?? 0;
    _reviewExisted = widget.review != null;

    _detailsController.text = widget.review?.description ?? '';
    _descriptionText = widget.review?.description ?? '';
    _initialDescription = widget.review?.description ?? '';

    _detailsController.addListener(() {
      if (mounted) {
        setState(() {
          _descriptionText = _detailsController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> handleReview() async {
    if (_initialRating == _rating &&
        _initialDescription == _detailsController.text) {
      return;
    }

    if (_rating == 0) {
      return;
    }

    if (_updateInProgress) {
      return;
    }
    if (mounted) {
      setState(() {
        _updateInProgress = true;
      });
    }

    var newReview = await reviewController.saveReview(
      _rating,
      widget.auction.value.id,
      _descriptionText,
      widget.review?.id,
    );

    if (newReview != null) {
      var reviewToUpdate = widget.auction.value.reviews
          ?.firstWhereOrNull((element) => element.id == newReview.id);
      if (reviewToUpdate != null) {
        reviewToUpdate.description = newReview.description;
        reviewToUpdate.stars = newReview.stars;
      } else {
        widget.auction.value.reviews?.add(newReview);
      }

      flashController.showMessageFlash(
        tr(_reviewExisted
            ? "auction_details.reviews.review_updated"
            : "auction_details.reviews.review_created"),
        FlashMessageType.success,
      );
      if (mounted) {
        setState(() {
          _reviewExisted = true;
          _updateInProgress = false;
          _initialDescription = _descriptionText;
          _initialRating = _rating;
        });
      }
      return;
    }

    flashController.showMessageFlash(
      tr(_reviewExisted
          ? "auction_details.reviews.could_not_update_review"
          : "auction_details.reviews.could_not_create_review"),
      FlashMessageType.error,
    );
    if (mounted) {
      setState(() {
        _updateInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var isPristine =
        _initialRating == _rating && _initialDescription == _descriptionText;

    var leaveReviewFor = tr("auction_details.reviews.would_you_leave_review");
    var reviewDetails = tr("auction_details.reviews.review_details");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context)
              .extension<CustomThemeFields>()!
              .separator
              .withOpacity(0.3),
        ),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: leaveReviewFor,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ),
                  TextSpan(
                    text: GenericUtils.generateNameForAccount(
                      widget.leaveReviewFor,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // ignore: unnecessary_null_comparison
                        if (widget.leaveReviewFor.id == null) {
                          return;
                        }

                        navigatorService.push(
                          ProfileDetailsScreen(
                            accountId: widget.leaveReviewFor.id,
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
                    text: ' ?',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ),
                ],
              ),
            ),
            Container(
              height: 16,
            ),
            RatingBar(
              initialRating: _rating,
              itemCount: 5,
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
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: (rating) {
                if (mounted) {
                  setState(() {
                    _rating = rating;
                  });
                }
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: TextField(
                maxLines: 4,
                minLines: 4,
                maxLength: 300,
                controller: _detailsController,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
                scrollPadding: const EdgeInsets.only(
                  bottom: 130,
                ),
                decoration: InputDecoration(
                  hintText: reviewDetails,
                  counterText: '',
                  fillColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_3,
                  hintStyle:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_2,
                        width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 16,
            ),
            SimpleButton(
              background: (_rating != 0) && !isPristine
                  ? Theme.of(context).extension<CustomThemeFields>()!.action
                  : Theme.of(context).extension<CustomThemeFields>()!.separator,
              isLoading: _updateInProgress,
              onPressed: () {
                handleReview();
              },
              height: 42,
              child: Text(
                'auction_details.reviews.save_review',
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontWeight: FontWeight.bold,
                      color: (_rating != 0) && !isPristine
                          ? DarkColors.font_1
                          : Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                    ),
              ).tr(),
            )
          ],
        ),
      ),
    );
  }
}
