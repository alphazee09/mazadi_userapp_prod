import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sign_in.dart';
import 'sign_up.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool _showSignIn = true;
  final Rx<bool> _pointerDownInner = false.obs;

  void toggleView() {
    if (mounted) {
      setState(() {
        _showSignIn = !_showSignIn;
      });
    }
  }

  void _handlePointerDown() {
    _pointerDownInner.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) {
              if (_pointerDownInner.value) {
                _pointerDownInner.value = false;
                return;
              }

              _pointerDownInner.value = false;
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _showSignIn
                    ? SignIn(
                        toggleView: toggleView,
                        handleInputPointerDown: _handlePointerDown,
                      )
                    : SignUp(
                        toggleView: toggleView,
                        handleInputPointerDown: _handlePointerDown,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
