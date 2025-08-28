import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/simple_button.dart';

class ConfirmSkipIntroDialog extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ConfirmSkipIntroDialog createState() => _ConfirmSkipIntroDialog();
}

class _ConfirmSkipIntroDialog extends State<ConfirmSkipIntroDialog> {
  final accountController = Get.find<AccountController>();
  bool _skipInProgress = false;

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
            child: Text(
              'intro.want_to_skip',
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
          ),
          Container(
            height: 16,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  Navigator.pop(context);
                },
                height: 42,
                width: 120,
                child: Text(
                  'generic.cancel',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 16,
            ),
            Expanded(
              child: IntrinsicWidth(
                child: SimpleButton(
                  isLoading: _skipInProgress,
                  borderColor: Colors.red,
                  background: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .separator,
                  onPressed: () async {
                    if (mounted) {
                      setState(() {
                        _skipInProgress = true;
                      });
                    }
                    var skipped = await accountController.skipIntro();
                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _skipInProgress = false;
                    });

                    if (!skipped) {
                      return;
                    }

                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).maybePop();
                    }
                  },
                  height: 42,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'intro.skip_intro',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
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
