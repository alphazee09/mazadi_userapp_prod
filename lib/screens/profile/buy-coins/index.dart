import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/controllers/payments.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/simple_app_bar.dart';
import '../widgets/watch_add_for_coins.dart';
import 'coins_card.dart';

class BuyCoinsScreen extends StatefulWidget {
  const BuyCoinsScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _BuyCoinsScreen createState() => _BuyCoinsScreen();
}

class _BuyCoinsScreen extends State<BuyCoinsScreen> {
  final paymentsController = Get.find<PaymentsController>();

  // ignore: non_constant_identifier_names
  var CARDS_COLORS = [
    Color(0xffF45C43),
    Color(0xffDC4973),
    Color(0xffAB4F8F),
  ];

  void goBack() {
    Navigator.of(context).pop();
  }

  Widget renderProduct(StoreProduct product, int index) {
    var colorOfTheCard = CARDS_COLORS[index % CARDS_COLORS.length];
    return BuyCoinsCard(
      background: colorOfTheCard,
      product: product,
    );
  }

  Widget renderEmptyProductsList() {
    return Column(
      children: [
        SvgPicture.asset(
          'assets/icons/categories/all.svg',
          height: 90,
          semanticsLabel: 'No results',
        ),
        const SizedBox(height: 20),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'buy_coins.no_products',
            style: Theme.of(context).extension<CustomThemeFields>()!.subtitle,
          ).tr(),
        ),
        Container(
          height: 24,
        ),
        WatchAddForCoinsCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        resizeToAvoidBottomInset: true,
        appBar: SimpleAppBar(
          onBack: goBack,
          withClearSearchKey: false,
          withSearch: false,
          elevation: 0,
          title: Row(
            children: [
              Flexible(
                child: Text(
                  'buy_coins.buy_coins',
                  style:
                      Theme.of(context).extension<CustomThemeFields>()!.title,
                ).tr(),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            width: Get.width,
            child: Obx(
              () => paymentsController.products.isEmpty
                  ? renderEmptyProductsList()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var product in paymentsController.products)
                          renderProduct(
                            product,
                            paymentsController.products.indexOf(product),
                          ),
                        WatchAddForCoinsCard(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
