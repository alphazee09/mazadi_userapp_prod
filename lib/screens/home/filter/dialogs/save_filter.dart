import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../theme/colors.dart';
import '../../../../widgets/common/simple_button.dart';

class SaveFilterDialog extends StatefulWidget {
  final Function onSubmit;

  const SaveFilterDialog({super.key, required this.onSubmit});

  @override
  // ignore: library_private_types_in_public_api
  _SaveFilterDialog createState() => _SaveFilterDialog();
}

class _SaveFilterDialog extends State<SaveFilterDialog> {
  final _nameController = TextEditingController();
  final Rx<bool> _pointerDownInner = false.obs;
  final Rx<int> _nameLength = 0.obs;

  bool _isSaving = false;

  Future<void> handleSave() async {
    if (_nameLength.value == 0) {
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    await widget.onSubmit(_nameController.text);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      Navigator.pop(context);
    }
  }

  Widget _renderDetailsInput(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          _pointerDownInner.value = true;
        },
        child: TextField(
          maxLines: 1,
          minLines: 1,
          maxLength: 100,
          controller: _nameController,
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
          scrollPadding: const EdgeInsets.only(
            bottom: 130,
          ),
          onChanged: (value) {
            _nameLength.value = value.length;
          },
          decoration: InputDecoration(
            hintText: tr("home.filter.save_filter_name"),
            counterText: '',
            fillColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_3,
            hintStyle:
                Theme.of(context).extension<CustomThemeFields>()!.smaller,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_2,
                  width: 0),
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
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (_pointerDownInner.value) {
          _pointerDownInner.value = false;
          return;
        }

        _pointerDownInner.value = false;
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: AlertDialog(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_2,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        titlePadding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'home.filter.save_filter_title',
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
              ),
              Text(
                'home.filter.save_filter_name',
                textAlign: TextAlign.left,
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ).tr(),
              _renderDetailsInput(context),
            ],
          ),
        ),
        actions: [
          Container(),
          Obx(
            () => SimpleButton(
              isLoading: _isSaving,
              background: _nameLength.value == 0
                  ? Theme.of(context).extension<CustomThemeFields>()!.separator
                  : Theme.of(context).extension<CustomThemeFields>()!.action,
              onPressed: () {
                handleSave();
              },
              height: 42,
              width: 120,
              child: Text(
                'generic.save',
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smaller
                    .copyWith(
                      color: _nameLength.value != 0
                          ? DarkColors.font_1
                          : Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                    ),
              ).tr(),
            ),
          ),
        ],
      ),
    );
  }
}
