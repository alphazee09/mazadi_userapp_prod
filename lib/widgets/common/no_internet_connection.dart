import 'package:mazadi/widgets/common/simple_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/controllers/main.dart';

class NoInternetConnectionScreen extends StatefulWidget {
  final Function? onTryAgain;

  const NoInternetConnectionScreen({
    super.key,
    this.onTryAgain,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NoInternetConnectionScreen createState() => _NoInternetConnectionScreen();
}

class _NoInternetConnectionScreen extends State<NoInternetConnectionScreen> {
  final mainController = Get.find<MainController>();

  bool _checkInProgress = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/svg/no-wifi.svg',
                height: 120,
                semanticsLabel: 'No internet connection',
              ),
              Container(
                height: 32,
              ),
              Text(
                "errors.no_internet",
                textAlign: TextAlign.center,
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ).tr(),
              Container(
                height: 32,
              ),
              SimpleButton(
                isLoading: _checkInProgress,
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                onPressed: () async {
                  if (_checkInProgress) {
                    return;
                  }
                  setState(() {
                    _checkInProgress = true;
                  });
                  await mainController.recheckNetworkConnectivity();
                  setState(() {
                    _checkInProgress = false;
                  });
                },
                height: 42,
                child: Text(
                  'errors.try_again',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                      ),
                ).tr(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
