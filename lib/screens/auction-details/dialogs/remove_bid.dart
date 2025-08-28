import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/flash.dart';
import '../../../widgets/common/simple_button.dart';

class RemoveBidDialogContent extends StatefulWidget {
  final Function onConfirm;

  const RemoveBidDialogContent({
    super.key,
    required this.onConfirm,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RemoveBidDialogContent createState() => _RemoveBidDialogContent();
}

class _RemoveBidDialogContent extends State<RemoveBidDialogContent> {
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

    var removed = false;
    try {
      var wasRemoved = await widget.onConfirm();
      if (!wasRemoved) {
        flashController.showMessageFlash(
          tr("generic.something_went_wrong"),
          FlashMessageType.error,
        );
      } else {
        flashController.showMessageFlash(
          tr("auction_details.bids.bid_was_removed"),
          FlashMessageType.success,
        );
        removed = true;
      }
    } catch (error) {
      flashController.showMessageFlash(
        tr("generic.something_went_wrong"),
        FlashMessageType.error,
      );
    }
    if (mounted) {
      setState(() {
        _removeInProgress = false;
      });
    }

    if (removed) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
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
                'auction_details.bids.sure_to_remove_bid',
                textAlign: TextAlign.center,
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ).tr(),
            ),
            Container(
              height: 16,
            ),
            Center(
              child: Text(
                "auction_details.bids.auction_owner_will_be_notified",
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
                      height: 20,
                      semanticsLabel: 'Remove bid',
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
