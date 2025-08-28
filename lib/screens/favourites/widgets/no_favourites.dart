import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoFavouriteAuctionsMessage extends StatelessWidget {
  final bool forClosedAuctions;

  const NoFavouriteAuctionsMessage({
    super.key,
    required this.forClosedAuctions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 32,
          ),
          SvgPicture.asset(
            'assets/icons/svg/favourite.svg',
            height: 160,
            semanticsLabel: 'Favourite heart',
          ),
          Container(
            height: 32,
          ),
          Text(
            forClosedAuctions
                ? 'favourites.app_bar.no_closed_auctions'
                : 'favourites.app_bar.no_active_auctions',
            style: Theme.of(context).extension<CustomThemeFields>()!.title,
            textAlign: TextAlign.center,
          ).tr(),
          Container(
            height: 32,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: tr('favourites.app_bar.tap_on_the'),
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ),
                WidgetSpan(
                  child: SvgPicture.asset(
                    'assets/icons/svg/heart.svg',
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      BlendMode.srcIn,
                    ),
                    semanticsLabel: 'Favourite heart',
                  ),
                ),
                TextSpan(
                  text: tr('favourites.app_bar.available_icon'),
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
