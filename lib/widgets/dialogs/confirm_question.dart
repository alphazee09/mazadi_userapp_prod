import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

import '../common/simple_button.dart';

class ConfirmQuestionDialog extends StatelessWidget {
  final String question;
  final bool? isDelete;

  const ConfirmQuestionDialog({
    super.key,
    required this.question,
    this.isDelete,
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
            child: Text(
              question,
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SimpleButton(
              background:
                  Theme.of(context).extension<CustomThemeFields>()!.separator,
              onPressed: () {
                Navigator.pop(context, false);
              },
              height: 42,
              width: 120,
              child: Text(
                'generic.no',
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
              ).tr(),
            ),
            SimpleButton(
              borderColor: isDelete == true
                  ? Theme.of(context).extension<CustomThemeFields>()!.action
                  : Colors.green,
              background:
                  Theme.of(context).extension<CustomThemeFields>()!.separator,
              onPressed: () {
                Navigator.pop(context, true);
              },
              height: 42,
              width: 140,
              child: Text('generic.yes',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller)
                  .tr(),
            ),
          ],
        ),
      ],
    );
  }
}
