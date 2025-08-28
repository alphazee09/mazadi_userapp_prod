import 'package:mazadi/widgets/common/input_like_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/auction.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/section_heading.dart';

class StartingAndEndingAuctionDatesSection extends StatelessWidget {
  final bool forEdit;

  StartingAndEndingAuctionDatesSection({
    super.key,
    this.forEdit = false,
  });

  final auctionController = Get.find<AuctionController>();

  Future<void> _openStartingDatePicker(BuildContext context) async {
    var minDate = DateTime.now().add(Duration(days: 1));
    var dateAfterOneMonth = minDate.add(Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: auctionController.startDate.value,
      firstDate: minDate,
      lastDate: dateAfterOneMonth,
    );

    if (picked == null) {
      return;
    }

    auctionController.startDate.value = picked;
    if (auctionController.endDate.value.isBefore(picked)) {
      auctionController.endDate.value = picked.add(Duration(days: 3));
    }
  }

  Future<void> _openEndDatePicker(BuildContext context) async {
    var currentDate = auctionController.startDate.value;
    var dateAfterOneMonth = currentDate.add(Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: auctionController.endDate.value,
      firstDate: auctionController.startDate.value.add(Duration(days: 1)),
      lastDate: dateAfterOneMonth,
    );

    if (picked == null) {
      return;
    }

    auctionController.endDate.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionHeading(
            title: tr('starting_soon_auctions.custom_start_date'),
            withMore: false,
            padding: 0,
            sufix: forEdit
                ? Container()
                : Obx(
                    () => Switch(
                      value: auctionController.customStartingDate.value,
                      activeColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .action,
                      onChanged: (bool value) {
                        auctionController.customStartingDate.value = value;
                      },
                    ),
                  ),
          ),
          Text(
            forEdit
                ? 'starting_soon_auctions.opted_for_custom'
                : 'starting_soon_auctions.will_automaticaly_start',
            style: Theme.of(context).extension<CustomThemeFields>()!.smallest,
          ).tr(),
          Obx(
            () => auctionController.customStartingDate.value == false
                ? Container()
                : Container(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .separator,
                      )),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'starting_soon_auctions.start_date',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .title
                                    .copyWith(
                                      color: Theme.of(context)
                                          .extension<CustomThemeFields>()!
                                          .fontColor_3,
                                    ),
                              ).tr(),
                              Container(
                                height: 4,
                              ),
                              Obx(
                                () => InputLikeButton(
                                  prefixIcon: Icon(
                                    Icons.calendar_month,
                                    color: Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .fontColor_3,
                                  ),
                                  placeholder: DateFormat(
                                          'd MMM', currentLanguage)
                                      .format(
                                          auctionController.startDate.value),
                                  onTap: () {
                                    _openStartingDatePicker(context);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          width: 16,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'starting_soon_auctions.end_date',
                                style: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .title
                                    .copyWith(
                                      color: Theme.of(context)
                                          .extension<CustomThemeFields>()!
                                          .fontColor_3,
                                    ),
                              ).tr(),
                              Container(
                                height: 4,
                              ),
                              InputLikeButton(
                                prefixIcon: Icon(
                                  Icons.calendar_month,
                                  color: Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .fontColor_3,
                                ),
                                placeholder: DateFormat(
                                        'd MMM', currentLanguage)
                                    .format(auctionController.endDate.value),
                                onTap: () {
                                  _openEndDatePicker(context);
                                },
                              ),
                            ],
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
