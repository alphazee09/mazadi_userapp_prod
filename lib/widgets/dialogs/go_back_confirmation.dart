import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

import '../common/simple_button.dart';

class GoBackConfirmationDialog extends StatelessWidget {
  final Function onSubmit;

  const GoBackConfirmationDialog({
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
            child: Text(
              'dialogs.sure_to_go_back',
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
          ),
          Container(
            height: 16,
          ),
          Center(
            child: Text(
              "dialogs.changes_will_be_discarded",
              textAlign: TextAlign.center,
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ).tr(),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  Navigator.pop(context);
                },
                height: 42,
                child: Text(
                  'generic.cancel',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: SimpleButton(
                borderColor: Colors.red,
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  onSubmit();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                height: 42,
                child: Text('dialogs.discard_changes',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller)
                    .tr(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
