import 'package:get/get.dart';

import 'base.dart';

class PaymentProduct {
  int coins;
  String productId;

  PaymentProduct({
    required this.coins,
    required this.productId,
  });

  static PaymentProduct fromJSON(dynamic data) {
    return PaymentProduct(
      coins: data['coins'],
      productId: data['productId'],
    );
  }
}

class PaymentRepository {
  final dio = Get.find<Api>();

  Future<List<PaymentProduct>> getProducts() async {
    try {
      var response = await dio.api.get('/payment/products');

      return List<PaymentProduct>.from(
        response.data.map(
          (el) => PaymentProduct.fromJSON(el),
        ),
      );
    } catch (error) {
      print('error loading payment products: $error');
      return [];
    }
  }
}
