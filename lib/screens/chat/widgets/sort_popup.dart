import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../widgets/common/popup_selected_item_bullet.dart';

enum ChatGroupsSortBy { newest, oldest }

class ChatGroupsSortPopup extends StatelessWidget {
  final Function(ChatGroupsSortBy) onSort;
  final ChatGroupsSortBy currentSort;

  const ChatGroupsSortPopup({
    super.key,
    required this.onSort,
    required this.currentSort,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: Colors.transparent,
        child: PopupMenuButton(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(29)),
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              'assets/icons/svg/sort.svg',
              height: 28,
              semanticsLabel: 'Sort',
              colorFilter: ColorFilter.mode(
                Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                BlendMode.srcIn,
              ),
            ),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              onTap: () {
                onSort(ChatGroupsSortBy.newest);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/svg/hourglass-top.svg',
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                        semanticsLabel: 'Newest',
                      ),
                      Container(
                        width: 8,
                      ),
                      Text(
                        'generic.newest',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .smaller,
                      ).tr(),
                    ],
                  ),
                  currentSort == ChatGroupsSortBy.newest
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                onSort(ChatGroupsSortBy.oldest);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    SvgPicture.asset(
                      'assets/icons/svg/hourglass-bottom.svg',
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        BlendMode.srcIn,
                      ),
                      semanticsLabel: 'Oldest',
                    ),
                    Container(
                      width: 8,
                    ),
                    Text(
                      'generic.oldest',
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                    ).tr(),
                  ]),
                  currentSort == ChatGroupsSortBy.oldest
                      ? const PopupSelectedItemBullet()
                      : Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
