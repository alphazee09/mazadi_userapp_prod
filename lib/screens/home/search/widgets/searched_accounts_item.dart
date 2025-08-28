import 'package:cached_network_image/cached_network_image.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/models/account.dart';
import '../../../../utils/generic.dart';
import '../../../../widgets/common/account_status_circle.dart';
import '../../../../widgets/common/image_error.dart';

class SearchedAccountsSuggestionItem extends StatelessWidget {
  final Account account;
  final Function? onTap;
  final BuildContext ctx;

  SearchedAccountsSuggestionItem({
    required this.account,
    required this.ctx,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(ctx).extension<CustomThemeFields>()!.background_1,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  children: [
                    ClipOval(
                      child: account.picture == ''
                          ? SvgPicture.asset(
                              'assets/icons/svg/user.svg',
                              semanticsLabel: 'User picture',
                            )
                          : CachedNetworkImage(
                              imageUrl: account.picture,
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                              maxWidthDiskCache: Get.width.toInt(),
                              maxHeightDiskCache: Get.height.toInt(),
                              errorWidget: (context, url, error) =>
                                  const ImageErrorWidget(),
                            ),
                    ),
                    AccountStatusCircle(
                      accountId: account.id,
                    )
                  ],
                ),
              ),
              Container(
                width: 16,
              ),
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        GenericUtils.generateNameForAccount(account),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(ctx)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
