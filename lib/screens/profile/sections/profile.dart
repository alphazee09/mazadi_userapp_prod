import 'package:mazadi/widgets/common/image_error.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/navigator.dart';
import '../details/index.dart';
import '../update/index.dart';

class ProfileSection extends StatelessWidget {
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          navigatorService.push(
            ProfileDetailsScreen(
              accountId: accountController.account.value.id,
            ),
            NavigationStyle.SharedAxis,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 1,
                    width: 1,
                  ),
                  Container(
                    margin: const EdgeInsetsDirectional.only(top: 16, end: 16),
                    child: ScaleTap(
                      onPressed: () {
                        navigatorService.push(
                          const UpdateProfileScreen(),
                          NavigationStyle.SharedAxis,
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .background_3
                              .withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/svg/edit.svg',
                              colorFilter: ColorFilter.mode(
                                Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                                BlendMode.srcIn,
                              ),
                              height: 24,
                              width: 24,
                              semanticsLabel: 'User picture',
                            ),
                            Container(
                              margin: EdgeInsetsDirectional.only(start: 8),
                              child: Text(
                                'profile.update_account',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .smaller,
                              ).tr(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 77),
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Obx(
                        () => ClipOval(
                          child: accountController.account.value.picture == ''
                              ? SvgPicture.asset(
                                  'assets/icons/svg/user.svg',
                                  semanticsLabel: 'User picture',
                                )
                              : CachedNetworkImage(
                                  imageUrl:
                                      accountController.account.value.picture,
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                  maxWidthDiskCache: Get.width.toInt(),
                                  maxHeightDiskCache: Get.height.toInt(),
                                  errorWidget: (context, url, error) =>
                                      const ImageErrorWidget(),
                                ),
                        ),
                      ),
                    ),
                    Obx(
                      () => accountController.account.value.name != ''
                          ? Container(
                              margin: const EdgeInsets.only(
                                  top: 16, left: 16, right: 16),
                              child: Text(
                                accountController.account.value.name ?? '',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .title
                                    .copyWith(
                                      color: Theme.of(context)
                                          .extension<CustomThemeFields>()!
                                          .fontColor_3,
                                    ),
                              ),
                            )
                          : Container(),
                    ),
                    Obx(
                      () => Container(
                        margin: EdgeInsets.symmetric(
                          vertical: accountController.account.value.name != ''
                              ? 8
                              : 16,
                          horizontal: 16,
                        ),
                        child: Text(
                          accountController.account.value.email,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: accountController.account.value.name != ''
                              ? Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller
                              : Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .title,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
