import 'package:mazadi/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/settings.dart';
import '../../../widgets/common/simple_button.dart';

class AddCustomStartingPriceDialog extends StatefulWidget {
  final Function onSubmit;
  final double? startingPrice;

  const AddCustomStartingPriceDialog({
    super.key,
    required this.onSubmit,
    this.startingPrice,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddCustomStartingPriceDialog createState() =>
      _AddCustomStartingPriceDialog();
}

class _AddCustomStartingPriceDialog
    extends State<AddCustomStartingPriceDialog> {
  final _inputController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final settingsController = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();
    if (widget.startingPrice != null) {
      _inputController.text = widget.startingPrice! % 1 == 0
          ? widget.startingPrice!.toInt().toString()
          : widget.startingPrice.toString();
    }
  }

  String? validatePrice(String? price) {
    if (price == null || price.isEmpty) {
      return tr('create_auction.price_cannot_be_empty');
    }

    try {
      var value = double.parse(price);
      if (value < 1 ||
          value > settingsController.settings.value.maxProductPrice) {
        return tr('create_auction.starting_price_condition', namedArgs: {
          'maxPrice':
              settingsController.settings.value.maxProductPrice.toString(),
        });
      }
    } catch (e) {
      return tr('create_auction.invalid_starting_price');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      titlePadding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'create_auction.starting_price',
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
          ),
          IconButton(
            splashRadius: 24,
            iconSize: 14,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/svg/close.svg',
              semanticsLabel: 'Close',
              height: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
          )
        ],
      ),
      content: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Form(
            key: _form, //assigning key to form
            child: Column(
              children: [
                TextFormField(
                  maxLines: 1,
                  minLines: 1,
                  maxLength: 50,
                  keyboardType: TextInputType.number,
                  controller: _inputController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                  scrollPadding: const EdgeInsets.only(
                    bottom: 130,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                  ],
                  validator: validatePrice,
                  decoration: InputDecoration(
                    errorMaxLines: 3,
                    hintText: tr('create_auction.add_starting_price'),
                    counterText: '',
                    fillColor: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_3,
                    hintStyle: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .background_2,
                        width: 0,
                      ),
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
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    errorStyle: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smallest
                        .copyWith(
                          color: Colors.red,
                          height: 0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: SimpleButton(
                background: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_3,
                onPressed: () async {
                  Navigator.pop(context);
                },
                height: 42,
                width: 120,
                child: Text(
                  'generic.cancel',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ),
            Container(
              width: 8,
            ),
            Expanded(
              child: SimpleButton(
                background:
                    Theme.of(context).extension<CustomThemeFields>()!.action,
                onPressed: () {
                  final isValid = _form.currentState?.validate();
                  if (isValid == null || !isValid) {
                    return;
                  }

                  widget.onSubmit(_inputController.text);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                height: 42,
                width: 120,
                child: Text(
                  'generic.done',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(color: DarkColors.font_1),
                ).tr(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
