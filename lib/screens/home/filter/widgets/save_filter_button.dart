import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/account.dart';
import '../../../../core/controllers/flash.dart';
import '../dialogs/save_filter.dart';

class SaveFilterButton extends StatelessWidget {
  final Function onSubmit;

  SaveFilterButton({super.key, required this.onSubmit});

  final accountController = Get.find<AccountController>();
  final flashController = Get.find<FlashController>();

  void openSaveFilterDialog() {
    var alert = SaveFilterDialog(
      onSubmit: onSubmit,
    );

    showDialog(
      context: navigator!.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      onPressed: () {
        openSaveFilterDialog();
      },
      onLongPress: () {},
      child: SizedBox(
        height: 24,
        child: Text(
          'home.filter.save_filter_title',
          style: Theme.of(context)
              .extension<CustomThemeFields>()!
              .smaller
              .copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
        ).tr(),
      ),
    );
  }
}
