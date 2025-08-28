import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/controllers/socket.dart';
import '../../theme/extensions/base.dart';

class AccountStatusCircle extends StatelessWidget {
  final socketController = Get.find<SocketController>();

  final String accountId;

  AccountStatusCircle({
    required this.accountId,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Obx(
        () => Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_3,
              width: 1,
            ),
            color: socketController.connectedAccounts
                        .firstWhereOrNull((el) => el == accountId) !=
                    null
                ? Colors.green
                : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
