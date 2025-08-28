import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/flash.dart';
import '../../../core/controllers/image_picker.dart';
import '../../../core/controllers/main.dart';
import '../../../theme/colors.dart';
import '../../../widgets/common/action_button.dart';
import '../../../widgets/common/section_heading.dart';
import '../../../widgets/common/simple_button.dart';
import '../../../widgets/dialogs/go_back_confirmation.dart';
import '../../../widgets/simple_app_bar.dart';
import '../dialogs/delete_confirmation.dart';
import 'location.dart';
import 'profile_picture.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final accountController = Get.find<AccountController>();
  final imagePickerController = Get.find<ImagePickerController>();
  final flashController = Get.find<FlashController>();
  final mainController = Get.find<MainController>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  final Rx<bool> _pointerDownInner = false.obs;

  String _initialName = '';
  bool _updated = false;
  bool _canUpdate = false;
  bool _isUpdating = false;
  bool _deleteInProgress = false;

  @override
  void initState() {
    _initialName = accountController.account.value.name!;
    _nameController.text = _initialName;
    _emailController.text = accountController.account.value.email;

    _nameController.addListener(handleNameChange);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.removeListener(handleNameChange);
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> deleteAccount() async {
    if (_deleteInProgress) {
      return;
    }

    setState(() {
      _deleteInProgress = true;
    });

    var deleted = await accountController.deleteAccount();

    setState(() {
      _deleteInProgress = false;
    });

    if (!deleted && mounted) {
      flashController.showMessageFlash(
        tr('profile.update.delete_account_error'),
        FlashMessageType.error,
      );
      return;
    }

    await mainController.signOut();
    // ignore: use_build_context_synchronously
    Navigator.pop(context);

    // ignore: use_build_context_synchronously
    Navigator.maybePop(context);
  }

  Future updateProfile() async {
    if (mounted) {
      setState(() {
        _isUpdating = true;
      });
    }

    try {
      var updated = await accountController.updateNameAndProfilePicture(
        _nameController.text,
      );

      var message = updated
          ? tr('profile.update.update_success')
          : tr('profile.update.update_error');

      if (mounted) {
        flashController.showMessageFlash(
          message,
          updated ? FlashMessageType.success : FlashMessageType.error,
        );
      }

      if (!mounted) {
        return;
      }

      if (updated) {
        imagePickerController.clear();
        if (mounted) {
          setState(() {
            _initialName = _nameController.text;
            _isUpdating = false;
            _canUpdate = false;
            _updated = true;
          });
        }
        return;
      }
    } catch (error) {
      flashController.showMessageFlash(
        tr('account.update.update_error'),
        FlashMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void handleNameChange() {
    if (!mounted) {
      return;
    }

    setState(() {
      _canUpdate = _nameController.text != _initialName;
    });
  }

  void showDeleteConfirmationDialog() {
    var alert = DeleteAccountConfirmationDialog(onSubmit: deleteAccount);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showGoBackConfirmationDialog(Function onSubmit) {
    var alert = GoBackConfirmationDialog(onSubmit: onSubmit);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void goBack() {
    if (imagePickerController.assetsAreSelected() || _canUpdate) {
      showGoBackConfirmationDialog(imagePickerController.clear);
      return;
    }

    Navigator.of(context).pop(_updated);
  }

  Widget renderTitle() {
    return Row(
      children: [
        Flexible(
          child: FittedBox(
            child: Row(
              children: [
                Text(
                  'profile.update.update_account',
                  textAlign: TextAlign.start,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                ).tr()
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget renderBodyContent() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          ProfileUpdateProfilePicture(),
          Container(
            height: 32,
          ),
          SectionHeading(
            title: tr('profile.update.application_name'),
            withMore: false,
            padding: 0,
          ),
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) {
              _pointerDownInner.value = true;
            },
            child: TextFormField(
              maxLines: 1,
              minLines: 1,
              maxLength: 50,
              controller: _nameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
              scrollPadding: const EdgeInsets.only(
                bottom: 130,
              ),
              decoration: InputDecoration(
                hintText: tr('profile.update.what_name_do_you_want'),
                counterText: '',
                fillColor: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_3,
                hintStyle:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .background_2,
                    width: 0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    width: 1,
                  ),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorStyle: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .smallest
                    .copyWith(
                      color: Colors.red,
                      height: 0,
                    ),
              ),
            ),
          ),
          Container(
            height: 16,
          ),
          SectionHeading(
            title: tr('home.filter.location'),
            withMore: false,
            padding: 0,
          ),
          ProfileUpdateLocation(),
          Container(
            height: 16,
          ),
          SectionHeading(
            title: tr('profile.update.email'),
            withMore: false,
            padding: 0,
          ),
          TextField(
            enabled: false,
            controller: _emailController,
            style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            onChanged: ((value) {}),
            decoration: InputDecoration(
              hintText: tr('profile.update.email'),
              suffixIcon: Padding(
                padding: EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/svg/ban.svg',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                    BlendMode.srcIn,
                  ),
                  semanticsLabel: 'Forbidden',
                  height: 12,
                  width: 12,
                ),
              ),
              counterText: '',
              fillColor: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_3,
              hintStyle:
                  Theme.of(context).extension<CustomThemeFields>()!.smaller,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_2,
                  width: 0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_1,
                  width: 1,
                ),
              ),
            ),
          ),
          Container(
            height: 16,
          ),
          Row(
            children: [
              Flexible(
                child: Text(
                  'profile.update.cannot_update_email',
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.smaller,
                ).tr(),
              ),
            ],
          ),
          Container(
            height: 32,
          ),
          ExpansionTile(
            iconColor: Theme.of(context).extension<CustomThemeFields>()!.action,
            tilePadding: EdgeInsetsDirectional.only(end: 0, start: 0),
            title: Text(
              'profile.update.delete_account',
              style: Theme.of(context).extension<CustomThemeFields>()!.title,
            ).tr(),
            children: [
              SimpleButton(
                filled: false,
                isLoading: _deleteInProgress,
                onPressed: () {
                  showDeleteConfirmationDialog();
                },
                borderColor: Colors.red,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'profile.update.delete_account',
                    style: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .smaller,
                  ).tr(),
                ),
              ),
              Container(
                height: 16,
              )
            ],
          ),
          Container(
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget renderBody() {
    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: renderBodyContent(),
        ),
      ),
    );
  }

  Widget renderBottomNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            Flexible(
              child: Obx(
                () => ActionButton(
                  onPressed: () {
                    if ((!_canUpdate &&
                            !imagePickerController.assetsAreSelected()) ||
                        _isUpdating) {
                      return;
                    }
                    updateProfile();
                  },
                  isLoading: _isUpdating,
                  background: (_canUpdate ||
                          imagePickerController.assetsAreSelected())
                      ? Theme.of(context).extension<CustomThemeFields>()!.action
                      : Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .separator,
                  height: 42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'profile.update.update_account',
                        style: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .title
                            .copyWith(
                              color: (_canUpdate ||
                                      imagePickerController.assetsAreSelected())
                                  ? DarkColors.font_1
                                  : Theme.of(context)
                                      .extension<CustomThemeFields>()!
                                      .fontColor_1,
                            ),
                      ).tr(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (_pointerDownInner.value) {
          _pointerDownInner.value = false;
          return;
        }

        _pointerDownInner.value = false;
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          resizeToAvoidBottomInset: true,
          appBar: SimpleAppBar(
            onBack: goBack,
            withSearch: false,
            elevation: 0,
            title: renderTitle(),
          ),
          body: renderBody(),
          bottomNavigationBar: renderBottomNavbar(),
        ),
      ),
    );
  }
}
