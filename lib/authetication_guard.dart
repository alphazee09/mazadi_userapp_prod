import 'dart:async';

import 'package:mazadi/screens/accept-terms/index.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/controllers/account.dart';
import 'core/controllers/flash.dart';
import 'core/controllers/terms.dart';
import 'core/navigator.dart';
import 'core/services/auth.dart';
import './root_screen.dart';
import 'screens/auth/index.dart';
import 'screens/home/preferred-categories/index.dart';
import 'widgets/common/loader.dart';

class AuthenticationGuard extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _AuthenticationGuardState createState() => _AuthenticationGuardState();
}

class _AuthenticationGuardState extends State<AuthenticationGuard> {
  final accountController = Get.find<AccountController>();
  final navigationService = Get.find<NavigatorService>();
  final flashController = Get.find<FlashController>();
  final authService = Get.find<AuthService>();
  final termsAndConditionsController = Get.find<TermsAndConditionController>();

  bool loggedUserLoading = false;

  late StreamSubscription<bool> _loggedUserLoadingSubscription;

  @override
  void initState() {
    super.initState();
    loggedUserLoading = authService.signinIn.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateCurrentLocaleToAccount();
      updateLastTimeInApp();
    });

    _loggedUserLoadingSubscription = authService.signinIn.listen((value) {
      if (!mounted) {
        return;
      }
      if (mounted) {
        setState(() {
          loggedUserLoading = value;
        });
      }

      if (value == true) {
        dontLetLoadingForever();
      }
    });
  }

  @override
  void dispose() {
    _loggedUserLoadingSubscription.cancel();
    super.dispose();
  }

  void updateCurrentLocaleToAccount() {
    var currentLocale = EasyLocalization.of(context)?.currentLocale;
    if (currentLocale == null) {
      return;
    }

    var account = accountController.account.value;
    var meta = account.meta;
    if (meta == null || meta.appLanguage == currentLocale.toString()) {
      return;
    }

    meta.appLanguage = currentLocale.toString();
    accountController.updateAccountMeta(meta);
  }

  void updateLastTimeInApp() {
    var account = accountController.account.value;
    var meta = account.meta;
    if (meta == null) {
      return;
    }

    meta.lastSignInTime = DateTime.now();
    accountController.updateAccountMeta(meta);
  }

  void dontLetLoadingForever() {
    Future.delayed(const Duration(seconds: 10), () async {
      if (loggedUserLoading == false || !mounted) {
        return;
      }

      flashController.showMessageFlash(
        tr('generic.something_went_wrong'),
        FlashMessageType.error,
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);

      if (mounted) {
        setState(() {
          loggedUserLoading = false;
        });
      }

      navigationService.push(
        const Authenticate(),
      );
    });
  }

  Widget renderBody() {
    return Obx(() {
      var account = accountController.account.value;
      if (account.id.isEmpty || account.id == '') {
        return Authenticate();
      }

      if (!termsAndConditionsController.acceptedTermsAndConditions.value ||
          !termsAndConditionsController.commited.value) {
        return AcceptsTermsOfServiceScreen();
      }

      if (!accountController.account.value.categoriesSetupDone) {
        return AccountPreferredCategoriesScreen();
      }

      return RootScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return loggedUserLoading ? Loader() : renderBody();
  }
}
