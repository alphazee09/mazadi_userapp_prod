import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flash/flash.dart';
import 'package:flutter/gestures.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/controllers/settings.dart';
import '../../core/services/auth.dart';
import '../../theme/colors.dart';
import '../../widgets/common/action_button.dart';
import '../../widgets/common/custom_search_input.dart';
import 'terms_and_conditions.dart';

class SignUp extends StatefulWidget {
  final Function toggleView;
  final Function? handleInputPointerDown;

  const SignUp({
    super.key,
    required this.toggleView,
    this.handleInputPointerDown,
  });

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final authService = Get.find<AuthService>();
  final settingsController = Get.find<SettingsController>();

  String email = '';
  String password = '';
  bool _passwordVisible = false;

  bool acceptedTermsAndCondition = false;
  bool acceptedNewsletter = false;

  bool _signUpInProgress = false;

  void handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!acceptedTermsAndCondition) {
      showTermsFlash();
      return;
    }

    if (mounted) {
      setState(() {
        _signUpInProgress = true;
      });
    }

    try {
      await authService.signUp(
        email,
        password,
        context,
      );
    } catch (error) {
      if (error.toString().contains('[firebase_auth/email-already-in-use]')) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          customSnackBar(
            content:
                'There already exists an account associated with this email',
          ),
        );
        return;
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        customSnackBar(
          content:
              'Could not sign up using these credentials. Please try again.',
        ),
      );
    }

    if (mounted) {
      setState(() {
        _signUpInProgress = false;
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

  void showTermsFlash() {
    var needToAccept = tr('auth.sign_up.need_to_accept');
    var terms = tr('auth.sign_up.terms_of_service');
    var toContinue = tr('auth.sign_up.to_continue');

    showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        builder: (context, controller) {
          return Flash(
            controller: controller,
            position: FlashPosition.bottom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: needToAccept,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                        ),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              var url = Uri.parse(settingsController
                                  .settings.value.confidentialityLink);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          text: terms,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller
                              .copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextSpan(
                          text: toContinue,
                          style: Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .smaller,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void toggleTermsAndCondition() {
    if (mounted) {
      setState(() {
        acceptedTermsAndCondition = !acceptedTermsAndCondition;
      });
    }
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return tr('auth.sign_up.email_empty');
    }

    var isValid = EmailValidator.validate(email);
    return !isValid ? tr('auth.sign_up.email_invalid') : null;
  }

  String? validatePassword(String? pass) {
    if (pass == null || pass.isEmpty) {
      return tr('auth.sign_up.password_empty');
    }

    if (pass.length < 6) {
      return tr('auth.sign_up.password_min_len');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    var emailPlaceholder = tr('auth.sign_up.email_placeholder');
    var passwordPlaceholder = tr('auth.sign_up.password_placeholder');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'auth.sign_up.sign_up',
          style: Theme.of(context)
              .extension<CustomThemeFields>()!
              .title
              .copyWith(fontSize: 30),
        ).tr(),
        Container(
          height: 8,
        ),
        Text(
          "auth.sign_up.lets_create_acc",
          style: Theme.of(context).extension<CustomThemeFields>()!.subtitle,
        ).tr(),
        Container(
          height: 8,
        ),
        Form(
          key: _formKey,
          child: Column(children: [
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
                    placeholder: emailPlaceholder,
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
              ),
            ),
            SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                        child: CustomInput(
                      handleInputPointerDown: widget.handleInputPointerDown,
                      verticalPadding: 16,
                      validator: validatePassword,
                      placeholder: passwordPlaceholder,
                      obscureText: _passwordVisible ? false : true,
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
                      withPrefixIcon: false,
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            password = value;
                          });
                        }
                      },
                    )),
                  ],
                ))
          ]),
        ),
        Container(
          height: 24,
        ),
        TermsAndConditionsCheck(
          onChange: toggleTermsAndCondition,
          value: acceptedTermsAndCondition,
        ),
        Container(
          height: 16,
        ),
        ActionButton(
          isLoading: _signUpInProgress,
          onPressed: handleSignUp,
          background: !acceptedTermsAndCondition
              ? Theme.of(context).extension<CustomThemeFields>()!.separator
              : Theme.of(context).extension<CustomThemeFields>()!.action,
          child: Text(
            'auth.sign_up.sign_up',
            style: Theme.of(context)
                .extension<CustomThemeFields>()!
                .smaller
                .copyWith(
                  color: !acceptedTermsAndCondition
                      ? Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .fontColor_1
                      : DarkColors.font_1,
                  fontWeight: FontWeight.w500,
                ),
          ).tr(),
        ),
        Container(
          height: 56,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'auth.sign_up.already_member',
              style: Theme.of(context).extension<CustomThemeFields>()!.subtitle,
            ).tr(),
            InkWell(
              onTap: () {
                widget.toggleView();
              },
              child: Text(
                'auth.sign_up.sign_in',
                style: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .subtitle
                    .copyWith(
                      color: Colors.blue,
                    ),
              ).tr(),
            )
          ],
        ),
      ],
    );
  }
}
