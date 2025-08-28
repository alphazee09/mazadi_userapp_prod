import 'dart:async';
import 'package:get/get.dart';
import '../models/account.dart';
import 'account.dart';

class TermsAndConditionController extends GetxController {
  final accountController = Get.find<AccountController>();

  Rx<bool> acceptedTermsAndConditions = false.obs;
  Rx<bool> commited = false.obs;
  late StreamSubscription<Account> _accountSubscription;

  @override
  void onInit() async {
    super.onInit();
    initDataFromAccount();

    _accountSubscription = accountController.account.listen((_) {
      initDataFromAccount();
    });
  }

  @override
  void dispose() {
    _accountSubscription.cancel();
    super.dispose();
  }

  void initDataFromAccount() {
    if (accountController.account.value.id.isEmpty ||
        accountController.account.value.id == '') {
      return;
    }

    var needsSave = false;
    if (acceptedTermsAndConditions.value == true &&
        accountController.account.value.acceptedTermsAndCondition == false) {
      needsSave = true;
    }

    if (needsSave) {
      commit();
      return;
    }

    acceptedTermsAndConditions.value =
        accountController.account.value.acceptedTermsAndCondition;
    if (accountController.account.value.acceptedTermsAndCondition) {
      commited.value = true;
    } else {
      commited.value = false;
    }
  }

  void toggleTermsAndConditions() {
    acceptedTermsAndConditions.value = !acceptedTermsAndConditions.value;
  }

  void commit() {
    commited.value = true;

    accountController.acceptTerms(
      acceptedTermsAndConditions.value,
    );
  }

  void clear() {
    acceptedTermsAndConditions.value = false;
    commited.value = false;
  }
}
