import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../core/controllers/auction.dart';
import '../../../widgets/common/section_heading.dart';

// ignore: must_be_immutable
class AuctionFormTitleSection extends StatefulWidget {
  Function? handleTitlePointerDown;

  AuctionFormTitleSection({
    super.key,
    this.handleTitlePointerDown,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AuctionFormTitleSectionState createState() =>
      _AuctionFormTitleSectionState();
}

class _AuctionFormTitleSectionState extends State<AuctionFormTitleSection> {
  final auctionController = Get.find<AuctionController>();

  final _titleController = TextEditingController();
  final RxInt _titleLength = 0.obs;

  @override
  void initState() {
    super.initState();
    _titleController.text = auctionController.title.value;
    _titleLength.value = auctionController.title.value.length;

    _titleController.addListener(() {
      auctionController.setTitle(_titleController.text);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var descriptionMsg = tr("create_auction.title");
    var addDescriptionMsg = tr("create_auction.enter_title");

    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: descriptionMsg,
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
                maxLines: 1,
                minLines: 1,
                maxLength: 70,
                controller: _titleController,
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
                scrollPadding: const EdgeInsets.only(
                  bottom: 130,
                ),
                onChanged: ((value) {
                  if (mounted) {
                    _titleLength.value = value.length;
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
                    _titleController.text = '';
                    _titleLength.value = 0;
                  },
                  child: _titleLength.value == 0
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
                  '$_titleLength/70',
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
