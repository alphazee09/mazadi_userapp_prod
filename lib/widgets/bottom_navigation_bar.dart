import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../core/controllers/chat.dart';
import 'common/pulsating_circle.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onClicked;

  const CustomBottomNavigationBar(
      {super.key, required this.currentIndex, required this.onClicked});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBar();
}

class _CustomBottomNavigationBar extends State<CustomBottomNavigationBar> {
  final chatController = Get.find<ChatController>();

  Widget getIcon(int index, bool isActive) {
    switch (index) {
      case 0:
        return isActive
            ? SvgPicture.asset(
                'assets/icons/svg/home-filled.svg',
                semanticsLabel: 'Home',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
                height: 24,
              )
            : SvgPicture.asset(
                'assets/icons/svg/home.svg',
                semanticsLabel: 'Home',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
                height: 24,
              );
      case 1:
        return isActive
            ? SvgPicture.asset(
                'assets/icons/svg/heart-filled.svg',
                semanticsLabel: 'heart',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
                height: 24,
              )
            : SvgPicture.asset(
                'assets/icons/svg/heart.svg',
                semanticsLabel: 'heart',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
                height: 24,
              );
      case 2:
        return isActive
            ? SvgPicture.asset(
                'assets/icons/svg/chat-filled.svg',
                semanticsLabel: 'Chat',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
                height: 24,
              )
            : Obx(
                () => Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svg/chat.svg',
                      semanticsLabel: 'Chat',
                      colorFilter: ColorFilter.mode(
                        Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        BlendMode.srcIn,
                      ),
                      height: 24,
                    ),
                    if (chatController.unreadMessagesExist())
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: PulsatingCircle(
                          color: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .action,
                        ),
                      )
                  ],
                ),
              );
      case 3:
        return isActive
            ? SvgPicture.asset(
                'assets/icons/svg/profile-filled.svg',
                semanticsLabel: 'Profile',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
                height: 24,
              )
            : SvgPicture.asset(
                'assets/icons/svg/profile.svg',
                semanticsLabel: 'Profile',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
                  BlendMode.srcIn,
                ),
                height: 24,
              );
      default:
        return Container();
    }
  }

  Widget getLabel(int index, bool isSelected) {
    switch (index) {
      case 0:
        return Text(
          tr('bottom_nav.home'),
          style: isSelected
              ? Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smallest
                  .copyWith(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .action,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )
              : Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smallest
                  .copyWith(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    fontSize: 12,
                  ),
        );
      case 1:
        return Text(
          tr('bottom_nav.favourites'),
          style: isSelected
              ? Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smallest
                  .copyWith(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .action,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )
              : Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smallest
                  .copyWith(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    fontSize: 12,
                  ),
        );
      case 2:
        return Text(
          tr('bottom_nav.chat'),
          style: isSelected
              ? Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smallest
                  .copyWith(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .action,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )
              : Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smallest
                  .copyWith(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    fontSize: 12,
                  ),
        );
      case 3:
        return Text(
          tr('bottom_nav.more'),
          style: isSelected
              ? Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smallest
                  .copyWith(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .action,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )
              : Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smallest
                  .copyWith(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    fontSize: 12,
                  ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar.builder(
      itemCount: 4,
      tabBuilder: (int index, bool isActive) {
        return Container(
          padding: EdgeInsets.only(top: 8),
          child: Column(
            children: [
              getIcon(index, isActive),
              Container(
                height: 4,
              ),
              getLabel(index, isActive),
            ],
          ),
        );
      },
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      borderColor: Theme.of(context).extension<CustomThemeFields>()!.separator,
      borderWidth: 3,
      activeIndex: widget.currentIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
      onTap: widget.onClicked,
      //other params
    );

    // return Container(
    //   decoration: BoxDecoration(
    //     border: Border(
    //       top: BorderSide(
    //         color: Theme.of(context).extension<CustomThemeFields>()!.separator,
    //         width: 1,
    //       ),
    //     ),
    //   ),
    //   child: SizedBox(
    //       child: BottomNavigationBar(
    //     currentIndex: widget.currentIndex,
    //     type: BottomNavigationBarType.fixed,
    //     elevation: 0,
    //     backgroundColor:
    //         Theme.of(context).extension<CustomThemeFields>()!.background_1,
    //     unselectedItemColor:
    //         Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
    //     selectedItemColor:
    //         Theme.of(context).extension<CustomThemeFields>()!.action,
    //     selectedLabelStyle: Theme.of(context)
    //         .extension<CustomThemeFields>()!
    //         .smallest
    //         .copyWith(
    //           color: Theme.of(context).extension<CustomThemeFields>()!.action,
    //           fontWeight: FontWeight.bold,
    //           fontSize: 12,
    //         ),
    //     unselectedLabelStyle: Theme.of(context)
    //         .extension<CustomThemeFields>()!
    //         .smallest
    //         .copyWith(
    //           color:
    //               Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
    //           fontSize: 12,
    //         ),
    //     showSelectedLabels: true,
    //     showUnselectedLabels: true,
    //     iconSize: 24,
    //     items: [
    //       BottomNavigationBarItem(
    //           activeIcon: Padding(
    //             padding: const EdgeInsets.symmetric(vertical: 4),
    //             child: SvgPicture.asset(
    //               'assets/icons/svg/home-filled.svg',
    //               semanticsLabel: 'Home',
    //               color: Theme.of(context)
    //                   .extension<CustomThemeFields>()!
    //                   .fontColor_1,
    //               height: 24,
    //             ),
    //           ),
    //           icon: Padding(
    //             padding: const EdgeInsets.symmetric(vertical: 4),
    //             child: SvgPicture.asset(
    //               'assets/icons/svg/home.svg',
    //               semanticsLabel: 'Home',
    //               color: Theme.of(context)
    //                   .extension<CustomThemeFields>()!
    //                   .fontColor_1,
    //               height: 24,
    //             ),
    //           ),
    //           tooltip: tr('bottom_nav.home'),
    //           label: tr('bottom_nav.home')),
    //       BottomNavigationBarItem(
    //         activeIcon: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 4),
    //           child: SvgPicture.asset(
    //             'assets/icons/svg/heart-filled.svg',
    //             semanticsLabel: 'heart',
    //             color: Theme.of(context)
    //                 .extension<CustomThemeFields>()!
    //                 .fontColor_1,
    //             height: 24,
    //           ),
    //         ),
    //         icon: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 4),
    //           child: SvgPicture.asset(
    //             'assets/icons/svg/heart.svg',
    //             semanticsLabel: 'heart',
    //             color: Theme.of(context)
    //                 .extension<CustomThemeFields>()!
    //                 .fontColor_1,
    //             height: 24,
    //           ),
    //         ),
    //         tooltip: tr('bottom_nav.favourites'),
    //         label: tr('bottom_nav.favourites'),
    //       ),
    //       BottomNavigationBarItem(
    //         activeIcon: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 4),
    //           child: SvgPicture.asset(
    //             'assets/icons/svg/heart.svg',
    //             semanticsLabel: 'heart',
    //             color: Theme.of(context)
    //                 .extension<CustomThemeFields>()!
    //                 .fontColor_1,
    //             height: 24,
    //           ),
    //         ),
    //         icon: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 4),
    //           child: SvgPicture.asset(
    //             'assets/icons/svg/add.svg',
    //             semanticsLabel: 'Add',
    //             color: Theme.of(context)
    //                 .extension<CustomThemeFields>()!
    //                 .fontColor_1,
    //             height: 24,
    //           ),
    //         ),
    //         tooltip: tr('bottom_nav.create'),
    //         label: tr('bottom_nav.create'),
    //       ),
    //       BottomNavigationBarItem(
    //         activeIcon: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 4),
    //           child: SvgPicture.asset(
    //             'assets/icons/svg/chat-filled.svg',
    //             semanticsLabel: 'Chat',
    //             color: Theme.of(context)
    //                 .extension<CustomThemeFields>()!
    //                 .fontColor_1,
    //             height: 24,
    //           ),
    //         ),
    //         icon: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 4),
    //           child: Obx(
    //             () => Stack(
    //               children: [
    //                 SvgPicture.asset(
    //                   'assets/icons/svg/chat.svg',
    //                   semanticsLabel: 'Chat',
    //                   color: Theme.of(context)
    //                       .extension<CustomThemeFields>()!
    //                       .fontColor_1,
    //                   height: 24,
    //                 ),
    //                 if (chatController.unreadMessagesExist())
    //                   Positioned(
    //                     bottom: 0,
    //                     right: 0,
    //                     child: PulsatingCircle(
    //                       color: Theme.of(context)
    //                           .extension<CustomThemeFields>()!
    //                           .action,
    //                     ),
    //                   )
    //               ],
    //             ),
    //           ),
    //         ),
    //         tooltip: tr('bottom_nav.chat'),
    //         label: tr('bottom_nav.chat'),
    //       ),
    //       BottomNavigationBarItem(
    //         activeIcon: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 4),
    //           child: SvgPicture.asset(
    //             'assets/icons/svg/profile-filled.svg',
    //             semanticsLabel: 'Profile',
    //             color: Theme.of(context)
    //                 .extension<CustomThemeFields>()!
    //                 .fontColor_1,
    //             height: 24,
    //           ),
    //         ),
    //         icon: Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 4),
    //           child: SvgPicture.asset(
    //             'assets/icons/svg/profile.svg',
    //             semanticsLabel: 'Profile',
    //             color: Theme.of(context)
    //                 .extension<CustomThemeFields>()!
    //                 .fontColor_1,
    //             height: 24,
    //           ),
    //         ),
    //         tooltip: tr('bottom_nav.more'),
    //         label: tr('bottom_nav.more'),
    //       )
    //     ],
    //     onTap: (index) {
    //       widget.onClicked(index);
    //     },
    //   )),
    // );
  }
}
