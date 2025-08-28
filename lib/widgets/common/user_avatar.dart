import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../../core/controllers/account.dart';
import '../../core/models/account.dart';
import '../../core/navigator.dart';
import '../../screens/profile/details/index.dart';
import 'account_status_circle.dart';
import 'image_error.dart';

// ignore: must_be_immutable
class UserAvatar extends StatelessWidget {
  Account? account;
  bool small;
  double? size;
  BorderRadius? radius;

  UserAvatar({
    super.key,
    this.account,
    this.small = false,
    this.size,
    this.radius,
  });

  final navigatorService = Get.find<NavigatorService>();
  final accountController = Get.find<AccountController>();

  @override
  Widget build(BuildContext context) {
    var accountToDisplay = account ?? accountController.account.value;

    return GestureDetector(
      onTap: () {
        navigatorService.push(
          ProfileDetailsScreen(
            accountId: accountToDisplay.id,
          ),
          NavigationStyle.SharedAxis,
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: radius ?? const BorderRadius.all(Radius.circular(50)),
            child: SizedBox(
              height: size ?? (small ? 46 : 60),
              width: size ?? (small ? 46 : 60),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius:
                      radius ?? const BorderRadius.all(Radius.circular(50)),
                ),
                child: ClipRRect(
                  borderRadius:
                      radius ?? const BorderRadius.all(Radius.circular(50)),
                  child: accountToDisplay.picture == ''
                      ? Container(
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: Svg(
                                'assets/icons/svg/user.svg',
                              ),
                            ),
                            borderRadius: radius ??
                                const BorderRadius.all(
                                  Radius.circular(2),
                                ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: accountToDisplay.picture,
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
          ),
          AccountStatusCircle(
            accountId: accountToDisplay.id,
          ),
        ],
      ),
    );
  }
}
