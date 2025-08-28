import 'package:mazadi/widgets/common/action_button.dart';
import 'package:mazadi/widgets/common/shaker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomInput extends StatefulWidget {
  final String placeholder;
  final bool withSufixIcon;
  final bool withPrefixIcon;
  final bool obscureText;

  final double? borderWidth;
  final Color? fillColor;
  final bool? withClearSearchKey;
  final bool? isLoading;

  final int? maxLength;
  final int? maxLines;

  final double? inputHeight;

  final Widget? prefixIcon;
  final Widget? sufixIcon;

  final TextInputType? keyboardType;

  final Function? onChanged;
  final Function? onTap;
  final Function? handleInputPointerDown;

  final String? initialSearchQuery;
  final String? Function(String?)? validator;
  final double verticalPadding;

  CustomInput({
    super.key,
    String? placeholder = 'Search books by keyword or ISBN',
    this.withPrefixIcon = true,
    this.onChanged,
    this.onTap,
    this.maxLines,
    this.maxLength,
    this.prefixIcon,
    this.sufixIcon,
    this.borderWidth,
    this.fillColor,
    this.validator,
    this.keyboardType,
    this.verticalPadding = 8,
    this.isLoading = false,
    this.withClearSearchKey,
    this.obscureText = false,
    this.withSufixIcon = true,
    this.initialSearchQuery = '',
    this.handleInputPointerDown,
    this.inputHeight,
  }) : placeholder =
            placeholder ?? tr('widgets.custom_search_input.placeholder');

  @override
  State<CustomInput> createState() => _CustomInput();
}

class _CustomInput extends State<CustomInput>
    with SingleTickerProviderStateMixin<CustomInput> {
  late AnimationController controller;

  final textEditingController = TextEditingController();
  final GlobalKey<CustomShakeWidgetState> _shakeKey = GlobalKey();

  var _searchKey = '';

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    super.initState();

    textEditingController.text = widget.initialSearchQuery ?? '';
    _searchKey = widget.initialSearchQuery ?? '';
  }

  @override
  void dispose() {
    _shakeKey.currentState?.dispose();
    textEditingController.dispose();
    controller.dispose();
    super.dispose();
  }

  Widget? _renderSufixIcon() {
    if (widget.isLoading == true) {
      return SizedBox(
        height: 20,
        width: 52,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: 20,
              width: 20,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_1,
                ),
              ),
            )
          ],
        ),
      );
    }

    if (widget.sufixIcon != null) {
      return widget.sufixIcon!;
    }

    if (widget.withClearSearchKey == null ||
        widget.withClearSearchKey == false) {
      return null;
    }

    if (widget.withClearSearchKey == true) {
      if (_searchKey == '') {
        return null;
      }

      return Container(
        margin: const EdgeInsetsDirectional.only(end: 4),
        child: IconButton(
          splashRadius: 24,
          icon: SvgPicture.asset(
            'assets/icons/svg/close.svg',
            semanticsLabel: 'Close',
            height: 16,
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {
            textEditingController.clear();
            if (mounted) {
              setState(() {
                _searchKey = '';
                if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
              });
            }
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ActionButton(
        background:
            Theme.of(context).extension<CustomThemeFields>()!.background_2,
        width: 30,
        height: 30,
        child: SvgPicture.asset(
          'assets/icons/svg/filter.svg',
          colorFilter: ColorFilter.mode(
            Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
            BlendMode.srcIn,
          ),
          width: 20,
          height: 20,
        ),
      ),
    );
  }

  Widget _renderActualTextField() {
    return TextFormField(
      controller: textEditingController,
      maxLength: widget.maxLength,
      validator: ((value) {
        var validationResult =
            widget.validator != null ? widget.validator!(value) : null;
        if (validationResult != null) {
          _shakeKey.currentState?.shake();
        }

        return validationResult;
      }),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onChanged: (value) {
        if (mounted) {
          setState(() {
            _searchKey = value;
          });
        }
        widget.onChanged != null ? widget.onChanged!(value) : null;
      },
      maxLines: widget.maxLines ?? 1,
      obscureText: widget.obscureText,
      style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
      decoration: InputDecoration(
        isDense: true,
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        errorStyle:
            Theme.of(context).extension<CustomThemeFields>()!.smallest.copyWith(
                  color: Colors.red,
                  height: 0,
                ),
        prefixIcon: widget.withPrefixIcon
            ? widget.prefixIcon ??
                Container(
                  padding: EdgeInsets.all(12),
                  height: 20,
                  width: 20,
                  child: SvgPicture.asset(
                    'assets/icons/svg/search.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                )
            : null,
        suffixIcon: _renderSufixIcon(),
        fillColor: widget.fillColor ??
            Theme.of(context).extension<CustomThemeFields>()!.background_2,
        hintText: widget.placeholder,
        hintStyle: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        filled: true,
        contentPadding: EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: widget.verticalPadding,
          top: widget.verticalPadding,
        ),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_2,
              width: widget.borderWidth ?? 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color:
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              width: widget.borderWidth ?? 1),
        ),
      ),
      textAlign: TextAlign.start,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (widget.handleInputPointerDown != null) {
          widget.handleInputPointerDown!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomShakeWidget(
          key: _shakeKey,
          child: widget.inputHeight != null
              ? SizedBox(
                  height: widget.inputHeight!,
                  child: _renderActualTextField(),
                )
              : _renderActualTextField(),
        ),
      ),
    );
  }
}
