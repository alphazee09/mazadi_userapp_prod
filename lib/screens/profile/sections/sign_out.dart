import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/auth.dart';
import '../../../core/controllers/main.dart';
import '../../../widgets/common/simple_button.dart';
import '../dialogs/sign_out.dart';

class ProfileSignOut extends StatelessWidget {
  final authController = Get.find<AuthController>();
  final mainController = Get.find<MainController>();

  void showSignOutDialog(BuildContext context) {
    var alert = SignOutDialog(onSubmit: () {
      authController.signOut();
      mainController.signOut();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SimpleButton(
        background: Theme.of(context).extension<CustomThemeFields>()!.separator,
        filled: true,
        text: tr('profile.sign_out'),
        onPressed: () {
          showSignOutDialog(context);
        },
      ),
    );
  }
}
