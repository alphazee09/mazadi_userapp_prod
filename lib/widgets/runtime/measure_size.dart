import 'package:flutter/material.dart';

class MeasureSize extends StatefulWidget {
  final Widget child;
  final Function onHeightAvailable;

  const MeasureSize({
    super.key,
    required this.child,
    required this.onHeightAvailable,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MeasureSize createState() => _MeasureSize();
}

class _MeasureSize extends State<MeasureSize> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_key.currentContext == null) {
        return;
      }

      final box = _key.currentContext!.findRenderObject();
      if (box is RenderBox) {
        final height = box.size.height;
        widget.onHeightAvailable(height);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        key: _key,
        child: widget.child,
      ),
    );
  }
}
