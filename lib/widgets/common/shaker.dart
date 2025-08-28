import 'dart:math';
import 'package:flutter/material.dart';

import '../../utils/animation_controller.dart';

class CustomShakeWidget extends StatefulWidget {
  const CustomShakeWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.shakeCount = 2,
    this.shakeOffset = 10,
    super.key,
  });

  final Widget child;
  final double shakeOffset;
  final int shakeCount;
  final Duration duration;

  @override
  // ignore: no_logic_in_create_state
  State<CustomShakeWidget> createState() => CustomShakeWidgetState(duration);
}

class CustomShakeWidgetState
    extends AnimationControllerState<CustomShakeWidget> {
  CustomShakeWidgetState(super.duration);

  @override
  void initState() {
    super.initState();
    animationController.addStatusListener(_updateStatus);
  }

  @override
  void dispose() {
    animationController.removeStatusListener(_updateStatus);
    super.dispose();
  }

  void _updateStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) {
        animationController.reset();
      }
    }
  }

  void shake() {
    if (mounted) {
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      child: widget.child,
      builder: (context, child) {
        final sineValue =
            sin(widget.shakeCount * 2 * pi * animationController.value);
        return Transform.translate(
          offset: Offset(sineValue * widget.shakeOffset, 0),
          child: child,
        );
      },
    );
  }
}
