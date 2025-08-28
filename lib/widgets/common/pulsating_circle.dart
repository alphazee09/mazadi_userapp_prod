import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

class PulsatingCircle extends StatefulWidget {
  final Color? color;

  const PulsatingCircle({
    super.key,
    this.color,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PulsatingCircleState createState() => _PulsatingCircleState();
}

class _PulsatingCircleState extends State<PulsatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 1.0, end: 5.0).animate(_animationController)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animation.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color ??
            Theme.of(context).extension<CustomThemeFields>()!.action,
        boxShadow: [
          BoxShadow(
              color: widget.color != null
                  ? widget.color!.withOpacity(0.5)
                  : Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .action
                      .withOpacity(0.5),
              blurRadius: _animation.value,
              spreadRadius: _animation.value)
        ],
      ),
    );
  }
}
