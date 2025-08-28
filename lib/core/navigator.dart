// ignore_for_file: constant_identifier_names

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:swipe_back_detector/swipe_back_detector.dart';

enum NavigationStyle { Default, SharedAxis, FadeThrough, Fade }

class NavigatorService extends GetxService {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic>? push(
    Widget child, [
    NavigationStyle navStyle = NavigationStyle.Default,
    bool popPrevious = false,
    bool withSwipeBack = true,
  ]) async {
    switch (navStyle) {
      case NavigationStyle.Default:
        return navigatorKey.currentState
            ?.push(MyCustomRoute(widget: child, withSwipeBack: withSwipeBack));

      case NavigationStyle.SharedAxis:
        if (popPrevious) {
          return navigatorKey.currentState?.pushAndRemoveUntil(
            FromRight(widget: child),
            (route) => route.isFirst,
          );
        }

        return navigatorKey.currentState?.push(FromRight(widget: child));

      case NavigationStyle.FadeThrough:
        return navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return _OpenContainerWrapper(
                widget: child,
                onClosed: (bool? xx) {
                  return;
                },
                transitionType: ContainerTransitionType.fade,
                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                  return Container();
                },
              );
            },
          ),
        );

      case NavigationStyle.Fade:
        return navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return _OpenContainerWrapper(
                widget: child,
                onClosed: (bool? xx) {
                  return;
                },
                transitionType: ContainerTransitionType.fade,
                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                  return Container();
                },
              );
            },
          ),
        );
    }
  }

  Future<dynamic>? navigateTo(String routeName) {
    return navigatorKey.currentState?.pushNamed(routeName);
  }
}

class _OpenContainerWrapper extends StatelessWidget {
  const _OpenContainerWrapper({
    required this.closedBuilder,
    required this.transitionType,
    required this.onClosed,
    required this.widget,
  });

  final CloseContainerBuilder closedBuilder;
  final ContainerTransitionType transitionType;
  final ClosedCallback<bool?> onClosed;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<bool>(
      transitionType: transitionType,
      openBuilder: (BuildContext context, VoidCallback _) {
        return Container();
      },
      onClosed: onClosed,
      tappable: false,
      closedBuilder: closedBuilder,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

class FromRight extends PageRouteBuilder {
  final RouteSettings? routeSettings;

  FromRight({
    required Widget widget,
    this.routeSettings,
  }) : super(
          settings: routeSettings,
          pageBuilder: (context, animation, animation2) {
            return widget;
          },
          transitionsBuilder: (context, animation, animation2, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            // return SwipeBackDetector(
            //   swipeAreaWidth: Get.width / 2,
            //   child: SlideTransition(
            //     position: animation.drive(tween),
            //     child: child,
            //   ),
            // );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          opaque: false,
          barrierDismissible: true,
        );
}

class MyCustomRoute extends PageRouteBuilder {
  final RouteSettings? routeSettings;
  final bool? withSwipeBack;

  MyCustomRoute({
    required Widget widget,
    this.routeSettings,
    this.withSwipeBack,
  }) : super(
          settings: routeSettings,
          pageBuilder: (context, animation, animation2) {
            return widget;
          },
          transitionsBuilder: (context, animation, animation2, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            if (withSwipeBack == false) {
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            }

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          opaque: false,
          barrierDismissible: true,
        );
}
