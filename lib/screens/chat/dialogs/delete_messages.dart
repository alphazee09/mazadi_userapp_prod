import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/flash.dart';
import '../../../widgets/common/simple_button.dart';

class RemoveChatMessagesDialogContent extends StatefulWidget {
  final Function onConfirm;

  const RemoveChatMessagesDialogContent({
    super.key,
    required this.onConfirm,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RemoveChatMessagesDialogContent createState() =>
      _RemoveChatMessagesDialogContent();
}

class _RemoveChatMessagesDialogContent
    extends State<RemoveChatMessagesDialogContent> {
  final flashController = Get.find<FlashController>();
  bool _removeInProgress = false;

  Future<void> handleRemove() async {
    if (_removeInProgress || !mounted) {
      return;
    }
    if (mounted) {
      setState(() {
        _removeInProgress = true;
      });
    }

    try {
      await widget.onConfirm();
      if (!mounted) {
        return;
      }

      flashController.showMessageFlash(
        'Messages were removed',
        FlashMessageType.success,
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        _removeInProgress = false;
      });
      flashController.showMessageFlash(
        'Something went wrong. Please try again.',
        FlashMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _removeInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      content: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                'chat.sure_you_want_to_delete',
                textAlign: TextAlign.center,
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ).tr(),
            ),
            Container(
              height: 16,
            ),
            Center(
              child: Text(
                "chat.permanently_deleted",
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smallest,
              ).tr(),
            ),
          ],
        ),
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
              child: IntrinsicWidth(
                child: SimpleButton(
                  borderColor: Colors.red,
                  isLoading: _removeInProgress,
                  background: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .separator,
                  onPressed: () {
                    handleRemove();
                  },
                  height: 42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/trash.svg',
                        semanticsLabel: 'Delete',
                        height: 20,
                        width: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                      ),
                      Container(
                        width: 8,
                      ),
                      Text(
                        'chat.delete',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
