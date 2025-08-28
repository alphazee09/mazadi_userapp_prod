import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class AccountAlloweNotificationItem extends StatefulWidget {
  final String title;
  final String? description;
  final bool value;
  final Function(bool) onChange;

  const AccountAlloweNotificationItem({
    super.key,
    required this.title,
    required this.value,
    required this.onChange,
    this.description,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AccountAlloweNotificationItemState createState() =>
      _AccountAlloweNotificationItemState();
}

class _AccountAlloweNotificationItemState
    extends State<AccountAlloweNotificationItem> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onChange(!value);
        setState(() {
          value = !value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.title,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller
                        .copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: value,
                      onChanged: (_) {
                        widget.onChange(!value);
                        setState(() {
                          value = !value;
                        });
                      },
                      side: BorderSide(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                      ),
                      checkColor: DarkColors.font_1,
                      activeColor: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .action,
                    )
                  ],
                )
              ],
            ),
            widget.description != null
                ? Text(
                    widget.description!,
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller
                        .copyWith(fontWeight: FontWeight.w100),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
