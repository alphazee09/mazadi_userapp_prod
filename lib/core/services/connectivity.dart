import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  Function? _onConnectivityChanged;

  void init(
      void Function(List<ConnectivityResult>)? onConnectivityChanged) async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(onConnectivityChanged);

    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }

    onConnectivityChanged?.call(result);

    if (onConnectivityChanged != null) {
      _onConnectivityChanged = onConnectivityChanged;
    }
  }

  Future<void> recheckConnectivity() async {
    try {
      var result = await _connectivity.checkConnectivity();
      if (_onConnectivityChanged != null) {
        _onConnectivityChanged?.call(result);
      }
    } on PlatformException {
      return;
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
