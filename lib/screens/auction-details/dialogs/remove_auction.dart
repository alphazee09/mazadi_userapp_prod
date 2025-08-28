import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/flash.dart';
import '../../../widgets/common/simple_button.dart';

class RemoveAuctionDialogContent extends StatefulWidget {
  final Function onConfirm;

  const RemoveAuctionDialogContent({
    super.key,
    required this.onConfirm,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RemoveAuctionDialogContent createState() => _RemoveAuctionDialogContent();
}

class _RemoveAuctionDialogContent extends State<RemoveAuctionDialogContent> {
  final flashController = Get.find<FlashController>();
  bool _removeInProgress = false;

  Future<void> handleRemove() async {
    if (_removeInProgress) {
      return;
    }
    if (mounted) {
      setState(() {
        _removeInProgress = true;
      });
    }

    try {
      var removed = await widget.onConfirm();
      if (mounted) {
        setState(() {
          _removeInProgress = false;
        });
      }

      if (removed) {
        flashController.showMessageFlash(
          tr("auction_details.dialogs.auction_removed"),
          FlashMessageType.success,
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        flashController.showMessageFlash(
          tr("generic.something_went_wrong"),
          FlashMessageType.error,
        );
      }
    } catch (error) {
      flashController.showMessageFlash(
        tr("generic.something_went_wrong"),
        FlashMessageType.error,
      );
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
                'auction_details.dialogs.sure_to_remove_auction',
                textAlign: TextAlign.center,
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ).tr(),
            ),
            Container(
              height: 16,
            ),
            Center(
              child: Text(
                "auction_details.dialogs.bidders_will_be_notified_after_remove",
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
              child: SimpleButton(
                borderColor: Colors.red,
                isLoading: _removeInProgress,
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.separator,
                onPressed: () {
                  handleRemove();
                },
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svg/trash.svg',
                      height: 24,
                      semanticsLabel: 'Delete',
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
                      'generic.remove',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                    ).tr(),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
