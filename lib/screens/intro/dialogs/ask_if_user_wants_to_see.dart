import 'package:mazadi/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/controllers/account.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/simple_button.dart';

class AskIfUserWantsToSeeIntroDialog extends StatelessWidget {
  final accountController = Get.find<AccountController>();

  final Function onSubmit;

  AskIfUserWantsToSeeIntroDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/svg/intro/lighthouse.svg',
                semanticsLabel: 'How it works',
                height: 50,
              ),
              Container(
                width: 16,
              ),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: tr('intro.would_you_like_to_see'),
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .title,
                      ),
                      TextSpan(
                        text: "mazadi",
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller
                            .copyWith(
                              fontFamily: GoogleFonts.abrilFatface().fontFamily,
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .action,
                              fontSize: 22,
                            ),
                      ),
                      TextSpan(
                        text: tr('intro.would_you_like_to_see_2'),
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .title,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
          Container(
            height: 16,
          ),
          Center(
            child: Text(
              'intro.a_guid_on_how_it_words',
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ).tr(),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  accountController.skipIntro();
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.of(context, rootNavigator: true).maybePop();
                },
                height: 42,
                child: Text(
                  'intro.not_now',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: IntrinsicWidth(
                child: SimpleButton(
                  borderColor: Colors.red,
                  background:
                      Theme.of(context).extension<CustomThemeFields>()!.action,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    onSubmit();
                  },
                  height: 42,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'intro.see_intro',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: DarkColors.font_1,
                          ),
                    ).tr(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
