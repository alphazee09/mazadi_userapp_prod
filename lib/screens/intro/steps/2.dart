// ignore_for_file: file_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/settings.dart';
import '../../../theme/colors.dart';
import '../../../theme/extensions/base.dart';

class IntroSecondStep extends StatelessWidget {
  final settingsController = Get.find<SettingsController>();

  IntroSecondStep({super.key});

  Widget _renderAppBottomIcons(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: SvgPicture.asset(
            'assets/icons/svg/home.svg',
            semanticsLabel: 'Home',
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
            height: 24,
          )),
          Expanded(
            child: SvgPicture.asset(
              'assets/icons/svg/heart.svg',
              semanticsLabel: 'heart',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
              height: 24,
            ),
          ),
          Expanded(
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).extension<CustomThemeFields>()!.action,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/svg/add.svg',
                semanticsLabel: 'Add',
                colorFilter: ColorFilter.mode(
                  DarkColors.font_1,
                  BlendMode.srcIn,
                ),
                height: 24,
              ),
            ),
          ),
          Expanded(
            child: SvgPicture.asset(
              'assets/icons/svg/chat.svg',
              semanticsLabel: 'Chat',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
              height: 24,
            ),
          ),
          Expanded(
            child: SvgPicture.asset(
              'assets/icons/svg/profile.svg',
              semanticsLabel: 'Profile',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
              height: 24,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var createAuctionMessage = tr('intro.create_auction.create_an_auction');
    var simplyMessage = tr('intro.create_auction.simply');
    var usingTheBooksMessage = tr('intro.create_auction.using_the_books');
    var otherUsersMessage = tr('intro.create_auction.other_users');
    var forThemMessage = tr('intro.create_auction.for_them');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 16,
        ),
        _renderAppBottomIcons(context),
        Container(
          height: 64,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: simplyMessage,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
              TextSpan(
                text: createAuctionMessage,
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextSpan(
                text: usingTheBooksMessage,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
              TextSpan(
                text: otherUsersMessage,
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextSpan(
                text: forThemMessage,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
            ],
          ),
        ),
        Container(
          height: 32,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: tr('intro.create_auction.become_visible'),
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
              TextSpan(
                text: tr('intro.create_auction.hours_active', namedArgs: {
                  'no': settingsController
                      .settings.value.auctionActiveTimeInHours
                      .toString(),
                }),
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextSpan(
                text: tr('intro.create_auction.to_bid'),
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
