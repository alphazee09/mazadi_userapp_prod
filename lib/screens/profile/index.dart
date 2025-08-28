import 'package:mazadi/screens/profile/widgets/watch_add_for_coins.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/controllers/account.dart';
import '../../core/controllers/main.dart';
import '../../core/navigator.dart';
import '../../widgets/common/no_internet_connection.dart';
import 'sections/auctions.dart';
import 'sections/bids.dart';
import 'sections/legal.dart';
import 'sections/preferences.dart';
import 'sections/profile.dart';
import 'sections/sign_out.dart';
import 'widgets/buy_coins_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final accountController = Get.find<AccountController>();
  final mainController = Get.find<MainController>();
  final navigatorService = Get.find<NavigatorService>();

  Future<void> _reloadData() {
    return accountController.loadAccountStats();
  }

  Widget renderContent() {
    return SingleChildScrollView(
      child: Container(
        width: Get.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.only(bottom: 16),
                color: Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_1,
                child: ProfileSection(),
              ),
            ),
            ProfileBuyCoinsCard(),
            Container(
              height: 16,
            ),
            ProfileAuctionsSection(),
            Container(
              height: 16,
            ),
            ProfileBidsSection(),
            WatchAddForCoinsCard(),
            Container(
              height: 16,
            ),
            ProfilePreferencesSection(),
            Container(
              height: 16,
            ),
            ProfileLegalSection(),
            Container(
              height: 16,
            ),
            ProfileSignOut(),
            Container(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      body: SafeArea(
        child: Obx(
          () => mainController.connectivity.contains(ConnectivityResult.none)
              ? const NoInternetConnectionScreen()
              : RefreshIndicator(
                  color: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .fontColor_1,
                  backgroundColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .separator,
                  onRefresh: () async {
                    await _reloadData();
                  },
                  child: renderContent(),
                ),
        ),
      ),
    );
  }
}
