import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/controllers/flash.dart';
import '../../core/services/auth.dart';
import '../../theme/colors.dart';
import '../../theme/extensions/base.dart';
import '../../widgets/common/action_button.dart';
import '../../widgets/common/custom_search_input.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final authService = Get.find<AuthService>();
  final flashController = Get.find<FlashController>();

  final Rx<bool> _pointerDownInner = false.obs;
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  bool _emailSendInProgress = false;

  void goBack() {
    Navigator.of(context).pop();
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return tr('auth.sign_in.email_empty');
    }

    var isValid = EmailValidator.validate(email);
    return !isValid ? tr('auth.sign_in.email_invalid') : null;
  }

  void handleSendForgotPasswordEmail() async {
    if (_emailSendInProgress) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (mounted) {
      setState(() {
        _emailSendInProgress = true;
      });
    }

    var result = await authService.sendForgotPasswordEmail(_email);
    if (result == ResetPassowrdStatus.success) {
      flashController.showMessageFlash(
        tr('auth.forgot_password.email_sent'),
        FlashMessageType.success,
      );

      if (mounted) {
        setState(() {
          _email = '';
        });
      }

      goBack();
    }

    if (result == ResetPassowrdStatus.accountDoesNotExist) {
      flashController.showMessageFlash(
        tr('auth.forgot_password.user_was_not_found'),
      );
    }

    if (result == ResetPassowrdStatus.error) {
      flashController.showMessageFlash(
        tr('auth.forgot_password.could_not_send_email'),
      );
    }

    if (mounted) {
      setState(() {
        _emailSendInProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: SafeArea(
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
          child: Scaffold(
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            resizeToAvoidBottomInset: true,
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'auth.forgot_password.title',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .title
                        .copyWith(fontSize: 30),
                  ).tr(),
                  Container(
                    height: 32,
                  ),
                  Text(
                    "auth.forgot_password.enter_email",
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
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
                                  handleInputPointerDown: () {
                                    _pointerDownInner.value = true;
                                  },
                                  verticalPadding: 16,
                                  validator: validateEmail,
                                  placeholder: tr('auth.sign_in.enter_email'),
                                  withSufixIcon: false,
                                  withPrefixIcon: false,
                                  onChanged: (value) {
                                    if (mounted) {
                                      setState(() {
                                        _email = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 8,
                  ),
                  Text(
                    "auth.forgot_password.you_will_receive",
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ).tr(),
                  Container(
                    height: 24,
                  ),
                  ActionButton(
                    onPressed: handleSendForgotPasswordEmail,
                    isLoading: _emailSendInProgress,
                    background: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .action,
                    child: Text(
                      'auth.forgot_password.reset',
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
                    height: 56,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'auth.forgot_password.return_to',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .subtitle,
                      ).tr(),
                      InkWell(
                        onTap: () {
                          goBack();
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
