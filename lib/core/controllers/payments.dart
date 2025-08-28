import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../repositories/payment.dart';
import 'account.dart';

enum PaymentResult { success, pending, error }

class PaymentsController extends GetxController {
  final accountController = Get.find<AccountController>();
  final paymentRepository = Get.find<PaymentRepository>();

  RxList<StoreProduct> products = RxList<StoreProduct>();

  // These payment products are data got from our server, not from Purchases SDK
  // We are storing them in order to show the coins amount for each product
  List<PaymentProduct> paymentProducts = [];

  @override
  void onClose() {
    products.clear();
    paymentProducts.clear();
    super.onClose();
  }

  Future<void> init(bool purchasesAvailable) async {
    products.clear();
    paymentProducts.clear();

    var paymentProductsData = await paymentRepository.getProducts();
    paymentProducts.addAll(paymentProductsData);

    var productIDs = paymentProducts.map((e) => e.productId);

    if (purchasesAvailable) {
      var loadedProducts = await Purchases.getProducts(
        productIDs.toList(),
        productCategory: ProductCategory.nonSubscription,
      );
      var sortedProductsByPrice = loadedProducts.toList()
        ..sort((a, b) => a.price.compareTo(b.price));

      products.refresh();
      products.addAll(sortedProductsByPrice);
    }
  }

  int getPointsForProduct(StoreProduct product) {
    return paymentProducts
        .firstWhere(
          (element) => element.productId == product.identifier,
          orElse: () => PaymentProduct(coins: 0, productId: product.identifier),
        )
        .coins;
  }

  Future<PaymentResult> purchaseProduct(StoreProduct product) async {
    try {
      await Purchases.purchaseStoreProduct(product);

      var coinsForProduct = getPointsForProduct(product);
      if (coinsForProduct != 0) {
        accountController.updateCoins(
            accountController.account.value.coins + coinsForProduct);
      }

      return PaymentResult.success;
    } on PlatformException catch (err) {
      var errorCode = PurchasesErrorHelper.getErrorCode(err);
      if (errorCode == PurchasesErrorCode.paymentPendingError) {
        return PaymentResult.pending;
      } else {
        return PaymentResult.error;
      }
    } catch (error) {
      return PaymentResult.error;
    }
  }
}
