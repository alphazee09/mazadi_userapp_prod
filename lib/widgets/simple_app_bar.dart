import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../core/navigator.dart';
import 'common/custom_search_input.dart';

// ignore: non_constant_identifier_names
var APP_BAR_HEIGHT = 70;

class SimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool withBack;
  final bool withSearch;
  final String searchPlaceholder;

  final Widget title;
  final Function? onBack;
  final Function? handleSearch;
  final Function? handleFilterTap;

  final Color? backgroundColor;
  final double? scrolledUnderElevation;

  final bool? isLoading;
  final bool? withClearSearchKey;
  final Widget? flexibleSpace;
  final Widget? sufixIcon;
  final Widget? bottom;
  final double? bottomHeight;
  final double? elevation;
  final String? initialSearchQuery;
  final Function? handleSearchInputTapDown;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(APP_BAR_HEIGHT +
      (withSearch == true ? 77 : 0) +
      (bottomHeight != null ? bottomHeight ?? 0 : 0));

  SimpleAppBar({
    super.key,
    required this.title,
    this.withBack = true,
    this.withSearch = true,
    String? searchPlaceholder,
    this.onBack,
    this.isLoading = false,
    this.handleSearch,
    this.handleFilterTap,
    this.bottom,
    this.flexibleSpace,
    this.backgroundColor,
    this.sufixIcon,
    this.actions = const [],
    this.scrolledUnderElevation,
    this.withClearSearchKey = false,
    this.elevation = 1,
    this.bottomHeight,
    this.initialSearchQuery,
    this.handleSearchInputTapDown,
  }) : searchPlaceholder = searchPlaceholder ?? tr('generic.search');

  final navigatorService = Get.find<NavigatorService>();

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 65,
      elevation: elevation,
      titleSpacing: 0,
      flexibleSpace: flexibleSpace,
      scrolledUnderElevation: scrolledUnderElevation ?? 2,
      systemOverlayStyle: Theme.of(context)
          .appBarTheme
          .systemOverlayStyle
          ?.copyWith(
            statusBarColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            statusBarIconBrightness:
                Get.isDarkMode ? Brightness.light : Brightness.dark,
          ),
      toolbarHeight:
          APP_BAR_HEIGHT + (bottomHeight != null ? bottomHeight ?? 61 : 0),
      backgroundColor: backgroundColor ??
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      leading: withBack
          ? Container(
              height: 24,
              margin: const EdgeInsetsDirectional.only(start: 16),
              child: IconButton(
                splashRadius: 24,
                icon: SvgPicture.asset(
                  isRTL
                      ? 'assets/icons/svg/next.svg'
                      : 'assets/icons/svg/previous.svg',
                  // ignore: deprecated_member_use
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_1,
                  semanticsLabel: 'Previous',
                ),
                onPressed: () {
                  if (onBack != null) {
                    onBack!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            )
          : null,
      bottom: withSearch
          ? PreferredSize(
              preferredSize: Size.fromHeight(
                  bottom != null ? (bottomHeight ?? 61) + 61 : 61),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 16,
                            bottom: 16,
                            left: 16,
                            right: 16,
                          ),
                          child: CustomInput(
                            handleInputPointerDown: handleSearchInputTapDown,
                            inputHeight: 45,
                            isLoading: isLoading,
                            withClearSearchKey: withClearSearchKey,
                            withSufixIcon:
                                sufixIcon == null && !withClearSearchKey!
                                    ? false
                                    : true,
                            sufixIcon: sufixIcon,
                            placeholder: searchPlaceholder,
                            onChanged: handleSearch,
                            initialSearchQuery: initialSearchQuery,
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottom != null ? bottom ?? Container() : Container()
                ],
              ),
            )
          : bottom != null
              ? PreferredSize(
                  preferredSize: Size.fromHeight(bottomHeight ?? 77),
                  child: bottom as Widget,
                )
              : null,
      title: title,
      actions: actions,
    );
  }
}
