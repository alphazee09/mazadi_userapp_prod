import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';

enum FlashMessageType { error, success }

class FlashController extends GetxController {
  void showMessageFlash(
    String message, [
    FlashMessageType type = FlashMessageType.error,
  ]) {
    var context = navigator!.context;

    context.showFlash(
      duration: const Duration(seconds: 3),
      builder: (context, controller) {
        return FlashBar(
          controller: controller,
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_2,
          surfaceTintColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_2,
          position: FlashPosition.bottom,
          content: IntrinsicHeight(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_2,
              ),
              child: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: type == FlashMessageType.error
                            ? Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .action
                            : Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .fontColor_1,
                        fontWeight: type == FlashMessageType.error
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showTransparendFlash(Widget child, [int seconds = 1]) {
    var context = navigator!.context;

    context.showFlash(
      duration: Duration(seconds: seconds),
      builder: (context, controller) {
        return FlashBar(
          controller: controller,
          position: FlashPosition.bottom,
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_2,
          surfaceTintColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_2,
          content: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_2,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
