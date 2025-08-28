import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../theme/colors.dart';

class TermsAndConditionsCheck extends StatelessWidget {
  final Function onChange;
  final bool value;

  const TermsAndConditionsCheck({
    super.key,
    required this.onChange,
    required this.value,
  });

  Future<void> openConfidentiality() async {
    var url = Uri.parse(
      FlutterConfig.get('CONFIDENTIALITY_LINK'),
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var accept = tr('auth.terms.accept');
    var termsOfService = tr('auth.terms.terms_of_service');
    var processing = tr('auth.terms.processing');
    var privacy = tr('auth.terms.privacy');

    return InkWell(
      onTap: () {
        onChange();
      },
      child: Row(
        children: [
          Transform.scale(
            scale: 1.4,
            child: Checkbox(
              side: BorderSide(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .fontColor_1,
              ),
              checkColor: DarkColors.font_1,
              activeColor:
                  Theme.of(context).extension<CustomThemeFields>()!.action,
              value: value,
              onChanged: (bool? value) {
                onChange();
              },
            ),
          ),
          Container(
            width: 8,
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: accept,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        openConfidentiality();
                      },
                    text: termsOfService,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller
                        .copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextSpan(
                    text: processing,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ),
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        openConfidentiality();
                      },
                    text: privacy,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller
                        .copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
