import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/account.dart';
import '../../../../core/controllers/flash.dart';
import '../../../../widgets/chips/filter_simple_chip.dart';
import '../../../../widgets/dialogs/confirm_question.dart';
import '../dialogs/about_saved_filters.dart';

class SavedFiltersCard extends StatefulWidget {
  final Function applyFilter;

  const SavedFiltersCard({
    super.key,
    required this.applyFilter,
  });

  @override
  // ignore: library_private_types_in_public_api
  _SavedFiltersState createState() => _SavedFiltersState();
}

class _SavedFiltersState extends State<SavedFiltersCard> {
  final accountController = Get.find<AccountController>();
  final flashController = Get.find<FlashController>();

  String? _filterRemoveInProgress;

  Future<void> _openRemoveSavedFilterDialog(String filterId) async {
    var alert = ConfirmQuestionDialog(
      question: tr('home.filter.sure_you_want_to_remove'),
      isDelete: true,
    );

    var confirmed = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _filterRemoveInProgress = filterId;
    });

    var deleted = await accountController.deleteFilterForAccount(filterId);

    setState(() {
      _filterRemoveInProgress = null;
    });

    if (deleted == true) {
      return;
    }

    flashController.showMessageFlash(tr('home.filter.filter_remove_error'));
  }

  void openAboutSaveFilterDialog() {
    var alert = AboutSavedFiltersDialog();

    showDialog(
      context: navigator!.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context)
          .extension<CustomThemeFields>()!
          .separator
          .withOpacity(0.6),
      padding: const EdgeInsetsDirectional.only(start: 16, top: 8, bottom: 8),
      width: Get.width,
      child: Obx(
        () => Row(
          children: [
            ScaleTap(
              onPressed: () {
                openAboutSaveFilterDialog();
              },
              child: SvgPicture.asset(
                'assets/icons/svg/diskette.svg',
                semanticsLabel: 'Saved Filter',
                height: 32,
              ),
            ),
            Container(
              width: 16,
            ),
            accountController.account.value.filters != null &&
                    accountController.account.value.filters!.isNotEmpty
                ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        for (var filter
                            in accountController.account.value.filters!)
                          Container(
                            margin: const EdgeInsetsDirectional.only(end: 8),
                            child: FilterSimpleChip(
                              background: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .background_3,
                              title: filter.name,
                              removeInProgress:
                                  _filterRemoveInProgress == filter.id,
                              onTap: () {
                                widget.applyFilter(filter.id);
                              },
                              onRemove: () {
                                _openRemoveSavedFilterDialog(filter.id);
                              },
                            ),
                          ),
                      ]),
                    ),
                  )
                : Flexible(
                    child: GestureDetector(
                      onTap: () {
                        openAboutSaveFilterDialog();
                      },
                      child: Text(
                        'home.filter.you_dont_have_saved_filters',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
