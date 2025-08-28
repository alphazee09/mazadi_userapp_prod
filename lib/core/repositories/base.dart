import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:get/get.dart';
import '../controllers/secured.dart';
import 'package:dio/dio.dart' as dio;

class Api extends GetxService {
  var api = Dio();
  String? accessToken;

  var securedController = Get.find<SecuredController>();

  late StreamSubscription<String> _jwtSubscription;

  Api() {
    _jwtSubscription = securedController.jwt.listen((value) {
      accessToken = value;
    });

    api.options.baseUrl = FlutterConfig.get('SERVER_URL');

    api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Authorization'] = '$accessToken';
          options.headers['Accept'] = 'application/json';
          options.headers['content-type'] = 'application/json';

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          error.printError();
          if (error.response.toString().contains('Token expired')) {
            var tokenRefreshed = await refreshToken();
            if (tokenRefreshed == false) {
              return handler.next(error);
            }
            return handler.resolve(await _retry(error.requestOptions));
          }

          if (error.response.toString().contains('Operation Forbidden')) {
            final firebaseInstance = FirebaseAuth.instance;
            await firebaseInstance.signOut();
          }
          return handler.next(error);
        },
      ),
    );
  }

  @override
  void onClose() {
    _jwtSubscription.cancel();
    super.onClose();
  }

  Future<dio.Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return api.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<bool> refreshToken() async {
    final firebaseInstance = FirebaseAuth.instance;
    var authUser = firebaseInstance.currentUser;
    if (authUser == null) {
      accessToken = null;
      return false;
    }

    var token = await authUser.getIdToken(true);
    if (token == null) {
      accessToken = null;
      return false;
    }

    securedController.setJwt(token);
    accessToken = token;
    return true;
  }
}
