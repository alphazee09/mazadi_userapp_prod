import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/controllers/account.dart';
import '../../core/models/account.dart';
import '../../utils/generic.dart';
import 'user_avatar.dart';

class AccountInfo extends StatelessWidget {
  final Account? account;
  final bool small;
  final Function? onTap;

  final accountController = Get.find<AccountController>();

  AccountInfo({
    super.key,
    this.account,
    this.small = false,
    this.onTap,
  });

  String _generateUserName() {
    var unknownValue = tr('generic.unknown');

    var accountToTake = account ?? accountController.account.value;
    if (accountToTake.name != null && accountToTake.name != '') {
      return accountToTake.name ?? '';
    }

    if (accountToTake.email != '') {
      var containsAt = accountToTake.email.indexOf('@');
      if (containsAt != -1) {
        return accountToTake.email.substring(0, containsAt);
      }

      return accountToTake.email;
    }

    return unknownValue;
  }

  @override
  Widget build(BuildContext context) {
    var accountToTake = account ?? accountController.account.value;

    return Row(
      children: [
        UserAvatar(
          account: accountToTake,
          small: small,
        ),
        Container(
          width: 16,
        ),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _generateUserName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: small
                          ? Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .subtitle
                          : Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .title
                              .copyWith(fontWeight: FontWeight.w300),
                    ),
                  )
                ],
              ),
              Container(
                height: 4,
              ),
              account?.reviews.length == null
                  ? Text(
                      'profile.no_reviews',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smallest,
                    ).tr()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 2),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/svg/star-filled.svg',
                              height: 16,
                              semanticsLabel: 'Review Star',
                              colorFilter: ColorFilter.mode(
                                Colors.amber,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 4,
                        ),
                        Flexible(
                          child: Text(
                            '${account?.reviewsAverage?.toStringAsFixed(2) ?? GenericUtils.computeReviewsAverage(account?.reviews ?? []).toStringAsFixed(2)} (${account?.reviews.length.toString()})',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .smaller
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
