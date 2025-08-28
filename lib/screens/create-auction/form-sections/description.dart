import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../core/controllers/auction.dart';
import '../../../widgets/common/section_heading.dart';

// ignore: must_be_immutable
class AuctionFormDescriptionSection extends StatefulWidget {
  Function? handleTitlePointerDown;

  AuctionFormDescriptionSection({
    super.key,
    this.handleTitlePointerDown,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionFormDescriptionSectionState createState() =>
      _AuctionFormDescriptionSectionState();
}

class _AuctionFormDescriptionSectionState
    extends State<AuctionFormDescriptionSection> {
  final newAuctionController = Get.find<AuctionController>();

  final _descriptionController = TextEditingController();
  final RxInt _descriptionLength = 0.obs;

  @override
  void initState() {
    super.initState();
    _descriptionController.text = newAuctionController.description.value;
    _descriptionLength.value = newAuctionController.description.value.length;

    _descriptionController.addListener(() {
      newAuctionController.setDescription(_descriptionController.text);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var descriptionMsg = tr("create_auction.description");
    var addDescriptionMsg = tr("create_auction.enter_description");
    var optionalMsg = tr('generic.optional');

    return Container(
      height: 210,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: descriptionMsg,
            titleSufix: optionalMsg,
            withMore: false,
            padding: 0,
          ),
          Flexible(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) {
                widget.handleTitlePointerDown?.call();
              },
              child: TextField(
                maxLines: 8,
                minLines: 8,
                maxLength: 500,
                controller: _descriptionController,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
                scrollPadding: const EdgeInsets.only(
                  bottom: 130,
                ),
                onChanged: ((value) {
                  if (mounted) {
                    _descriptionLength.value = value.length;
                  }
                }),
                decoration: InputDecoration(
                  hintText: addDescriptionMsg,
                  counterText: '',
                  fillColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_2,
                  hintStyle:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_2,
                        width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => ScaleTap(
                  onPressed: () {
                    _descriptionController.text = '';
                    _descriptionLength.value = 0;
                  },
                  child: _descriptionLength.value == 0
                      ? Container()
                      : Text(
                          'generic.clear',
                          textAlign: TextAlign.right,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smallest
                              .copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                        ).tr(),
                ),
              ),
              Obx(
                () => Text(
                  '$_descriptionLength/500',
                  textAlign: TextAlign.right,
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smallest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
