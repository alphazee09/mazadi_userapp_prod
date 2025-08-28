import 'package:get/get.dart';
import 'account.dart';
import 'secured.dart';

class AuthController extends GetxController {
  final accountController = Get.find<AccountController>();
  final securedController = Get.find<SecuredController>();

  void signOut() async {
    securedController.setJwt('');
    accountController.setAccount(null);
  }
}
