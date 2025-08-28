// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/controllers/auth.dart';
import '../../core/controllers/secured.dart';
import '../../core/navigator.dart';
import '../../core/services/auth.dart';
import '../../theme/colors.dart';
import '../../widgets/common/action_button.dart';
import '../../widgets/common/custom_search_input.dart';
import 'reset_password.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  final Function? handleInputPointerDown;

  const SignIn({
    super.key,
    required this.toggleView,
    this.handleInputPointerDown,
  });

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final securedController = Get.find<SecuredController>();
  final navigatorService = Get.find<NavigatorService>();
  final authController = Get.find<AuthController>();
  final authService = Get.find<AuthService>();

  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';

  bool _signInInProgress = false;
  bool _emailSignInProgress = false;
  bool _passwordVisible = false;

  bool _iosSignInProgress = false;
  bool _googleSignInProgress = false;

  @override
  void initState() {
    super.initState();
    _clearCacheIfFirstOpenedApp();
  }

  Future<void> _clearCacheIfFirstOpenedApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seen = (prefs.getBool('seen') ?? false);

    if (!seen) {
      await prefs.setBool('seen', true);
      securedController.clearAll();
    }
  }

  void handleAnonymousSignIn() async {
    if (_signInInProgress) {
      return;
    }

    if (mounted) {
      setState(() {
        _signInInProgress = true;
      });
    }

    try {
      await authService.signInAnonymous();
    } catch (error) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content: 'Could not sign in. Please try again',
        ),
      );
    }

    if (mounted) {
      setState(() {
        _signInInProgress = false;
      });
    }
  }

  void handleEmailPassSignIn() async {
    if (_signInInProgress) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (mounted) {
      setState(() {
        _signInInProgress = true;
        _emailSignInProgress = true;
      });
    }

    try {
      await authService.signInWithEmailAndPass(email, password);
    } catch (error) {
      if (error.toString().contains('[firebase_auth/wrong-password]')) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content: 'Could not sign in. Invalid credentials',
          ),
        );
        return;
      }
      if (error.toString().contains('[firebase_auth/user-not-found]')) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content: 'Could not sign in. Credentials not found',
          ),
        );
        return;
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content: 'Could not sign in. Please try again',
        ),
      );
    }

    if (mounted) {
      setState(() {
        _signInInProgress = false;
        _emailSignInProgress = false;
      });
    }
  }

  void handleIOSSignIn() async {
    if (_signInInProgress) {
      return;
    }

    if (mounted) {
      setState(() {
        _signInInProgress = true;
        _iosSignInProgress = true;
      });
    }

    try {
      await authService.signInWithApple();
    } on FirebaseAuthException catch (e) {
      handleAuthException(e);
    } catch (e) {
      print('Could not login with apple $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content: 'Error occurred using Apple Sign-In. Try again.',
        ),
      );
    }

    if (mounted) {
      setState(() {
        _signInInProgress = false;
        _iosSignInProgress = false;
      });
    }
  }

  void handleGoogleSignIn() async {
    if (_signInInProgress) {
      return;
    }
    if (mounted) {
      setState(() {
        _signInInProgress = true;
        _googleSignInProgress = true;
      });
    }

    try {
      await authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      handleAuthException(e);
    } catch (e) {
      print('Could not login with google $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content: 'Could not sign in with google. Please try again.',
        ),
      );
    }

    if (mounted) {
      setState(() {
        _signInInProgress = false;
        _googleSignInProgress = false;
      });
    }
  }

  customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        textAlign: TextAlign.center,
        style:
            Theme.of(context).extension<CustomThemeFields>()!.smaller.copyWith(
                  color: Colors.red,
                ),
      ),
    );
  }

  void handleAuthException(FirebaseAuthException e) {
    print('HANDLE AUTH EXCE $e');
    if (e.code == 'account-exists-with-different-credential') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content: 'The account already exists with a different credential.',
        ),
      );
    } else if (e.code == 'invalid-credential') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content: 'Error occurred while accessing credentials. Try again.',
        ),
      );
    }
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return tr('auth.sign_in.email_empty');
    }

    var isValid = EmailValidator.validate(email);
    return !isValid ? tr('auth.sign_in.email_invalid') : null;
  }

  String? validatePassword(String? pass) {
    if (pass == null || pass.isEmpty) {
      return tr('auth.sign_in.password_empty');
    }

    return null;
  }

  Container _renderAlterativeDecor(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
            Theme.of(context)
                .extension<CustomThemeFields>()!
                .background_1
                .withOpacity(0.7),
            Theme.of(context).extension<CustomThemeFields>()!.background_2
          ],
          stops: const [0.0, 0.1, 1],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var enterEmailPlaceholder = tr('auth.sign_in.enter_email');
    var enterPasswordPlaceholder = tr('auth.sign_in.enter_password');

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'auth.sign_in.sign_in',
            style: Theme.of(context)
                .extension<CustomThemeFields>()!
                .title
                .copyWith(fontSize: 30),
          ).tr(),
          Container(
            height: 8,
          ),
          Text(
            'auth.sign_in.enter_credentials',
            style: Theme.of(context).extension<CustomThemeFields>()!.subtitle,
          ).tr(),
          Container(
            height: 8,
          ),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                            child: CustomInput(
                          handleInputPointerDown: widget.handleInputPointerDown,
                          verticalPadding: 16,
                          validator: validateEmail,
                          placeholder: enterEmailPlaceholder,
                          withSufixIcon: false,
                          withPrefixIcon: false,
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                email = value;
                              });
                            }
                          },
                        )),
                      ],
                    )),
                SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                            child: CustomInput(
                          handleInputPointerDown: widget.handleInputPointerDown,
                          verticalPadding: 16,
                          validator: validatePassword,
                          placeholder: enterPasswordPlaceholder,
                          obscureText: _passwordVisible ? false : true,
                          withPrefixIcon: false,
                          sufixIcon: Padding(
                            padding: const EdgeInsetsDirectional.only(end: 4),
                            child: IconButton(
                              splashRadius: 24,
                              iconSize: 24,
                              icon: SvgPicture.asset(
                                _passwordVisible
                                    ? 'assets/icons/svg/moon.svg'
                                    : 'assets/icons/svg/sun.svg',
                                semanticsLabel: 'Show password',
                                height: _passwordVisible ? 20 : 24,
                                width: _passwordVisible ? 20 : 24,
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .fontColor_1,
                                  BlendMode.srcIn,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            if (mounted) {
                              setState(() {
                                password = value;
                              });
                            }
                          },
                        )),
                      ],
                    )),
              ],
            ),
          ),
          Container(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ScaleTap(
                onPressed: () {
                  navigatorService.push(
                    const ResetPasswordScreen(),
                  );
                },
                child: Text(
                  'auth.sign_in.forgot_password',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ],
          ),
          Container(
            height: 24,
          ),
          ActionButton(
            onPressed: handleEmailPassSignIn,
            isLoading: _emailSignInProgress,
            background:
                Theme.of(context).extension<CustomThemeFields>()!.action,
            child: Text(
              'auth.sign_in.sign_in',
              style: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .smaller
                  .copyWith(
                    color: DarkColors.font_1,
                    fontWeight: FontWeight.w500,
                  ),
            ).tr(),
          ),
          Container(
            height: 40,
          ),
          Row(
            children: [
              Flexible(child: _renderAlterativeDecor(context)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'auth.sign_in.continue_with',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .subtitle,
                ).tr(),
              ),
              Flexible(
                  child: Transform.rotate(
                angle: math.pi,
                child: _renderAlterativeDecor(context),
              ))
            ],
          ),
          Container(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (Platform.isIOS)
                _iosSignInProgress
                    ? const SpinKitThreeBounce(
                        color: DarkColors.font_1,
                        size: 20,
                      )
                    : ScaleTap(
                        onPressed: handleIOSSignIn,
                        child: SvgPicture.asset(
                          'assets/icons/social/apple.svg',
                          height: 42,
                          semanticsLabel: 'apple',
                          colorFilter: Get.isDarkMode
                              ? ColorFilter.mode(
                                  DarkColors.font_1,
                                  BlendMode.srcIn,
                                )
                              : null,
                        ),
                      ),
              _googleSignInProgress
                  ? const SpinKitThreeBounce(
                      color: DarkColors.font_1,
                      size: 20,
                    )
                  : ScaleTap(
                      onPressed: handleGoogleSignIn,
                      child: SvgPicture.asset(
                        'assets/icons/social/google.svg',
                        height: 38,
                        semanticsLabel: 'google',
                      ),
                    )
            ],
          ),
          Container(
            height: 56,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'auth.sign_in.not_a_member',
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.subtitle,
              ).tr(),
              InkWell(
                onTap: () {
                  widget.toggleView();
                },
                child: Text(
                  'auth.sign_in.register_now',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .subtitle
                      .copyWith(
                        color: Colors.blue,
                      ),
                ).tr(),
              ),
            ],
          ),
          Container(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  handleAnonymousSignIn();
                },
                child: Text(
                  'auth.sign_in.continue_as_anon',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .subtitle
                      .copyWith(color: Colors.blue),
                ).tr(),
              )
            ],
          )
        ]);
  }
}
