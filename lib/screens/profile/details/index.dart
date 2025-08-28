import 'package:mazadi/core/controllers/auction.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:extended_sliver/extended_sliver.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/main.dart';
import '../../../core/models/account.dart';
import '../../../utils/generic.dart';
import '../../../widgets/common/no_internet_connection.dart';
import 'reviews/summary.dart';
import 'widgets/shimmer.dart';
import 'widgets/auctions.dart';
import 'widgets/hero.dart';
import 'widgets/more_actions_popup.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String accountId;

  const ProfileDetailsScreen({
    super.key,
    required this.accountId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfileDetailsScreen createState() => _ProfileDetailsScreen();
}

class _ProfileDetailsScreen extends State<ProfileDetailsScreen>
    with SingleTickerProviderStateMixin {
  final accountController = Get.find<AccountController>();
  final auctionController = Get.find<AuctionController>();
  final mainController = Get.find<MainController>();

  late Rx<Account>? _account;
  var _loadingAccount = true;

  @override
  void initState() {
    loadInitialData();
    super.initState();
  }

  Future<void> loadInitialData() async {
    var detailsPromise =
        accountController.loadAccountDetailsById(widget.accountId);

    var details = await detailsPromise;
    if (!mounted) {
      return;
    }

    if (mounted) {
      setState(() {
        _loadingAccount = false;
        _account = (details as Account).obs;
      });
    }
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  Widget _renderBody() {
    bool isRTL = Directionality.of(context)
        .toString()
        .contains(TextDirection.RTL.value.toLowerCase());

    var isCurentAccount =
        accountController.account.value.id == _account?.value.id;
    var accountName = GenericUtils.generateNameForAccount(_account!.value);

    return NestedScrollView(
      headerSliverBuilder: ((context, innerBoxIsScrolled) {
        return [
          ExtendedSliverAppbar(
            statusbarHeight: 1,
            toolBarColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            actions: Container(
              margin: const EdgeInsetsDirectional.only(end: 16),
              child: Row(children: [
                isCurentAccount
                    ? Container()
                    : ProfileDetailsMoreActionsPopup(
                        account: _account!,
                      ),
              ]),
            ),
            leading: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16),
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      splashRadius: 24,
                      icon: SvgPicture.asset(
                        isRTL
                            ? 'assets/icons/svg/next.svg'
                            : 'assets/icons/svg/previous.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .extension<CustomThemeFields>()!
                              .fontColor_1,
                          BlendMode.srcIn,
                        ),
                        semanticsLabel: 'Previous',
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Text(
                  accountName.length > 19
                      ? '${accountName.substring(0, 19)}...'
                      : accountName,
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            background: IntrinsicHeight(
              child: ProfileDetailsHero(
                account: _account!,
                reloadAccount: loadInitialData,
              ),
            ),
          ),
        ];
      }),
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          child: Column(
            children: [
              Container(
                height: 24,
              ),
              AccountAuctions(
                auctions: _account!.value.auctions,
                auctionsCount: _account!.value.activeAuctionsCount,
                account: _account!.value,
              ),
              Container(
                height: 24,
              ),
              AccountReviewsSummary(
                reviewsAverage: _account!.value.reviewsAverage,
                reviews: _account?.value.reviews ?? [],
                count: _account?.value.reviewsCount ?? 0,
                accountId: _account!.value.id,
              ),
              Container(
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loadingAccount
        ? AccountDetailsShimmer(
            isCurrentUser:
                accountController.account.value.id == widget.accountId,
          )
        : Scaffold(
            backgroundColor:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: _account == null
                  ? Container()
                  : Obx(
                      () => mainController.connectivity
                              .contains(ConnectivityResult.none)
                          ? const NoInternetConnectionScreen()
                          : _renderBody(),
                    ),
            ),
          );
  }
}
