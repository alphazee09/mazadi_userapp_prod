import 'dart:async';
import 'dart:convert';

import 'package:flutter_config/flutter_config.dart';

import 'package:get/get.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../controllers/account.dart';
import '../controllers/secured.dart';

enum CustomMessages {
  bidAccepted,
  bidRejected,
  newMessage,
  messagesRemoved,
  coinsUpdated,
  allConnectedAccounts,
  newConnectedAccount,
  accountDisconnected,
  myAuctionStarted,
  auctionFromFavouritesStarted,
}

class SocketService extends GetxService {
  final securedController = Get.find<SecuredController>();
  final accountController = Get.find<AccountController>();

  late IO.Socket socket;
  String? accessToken;
  bool initDone = false;

  // ignore: prefer_typing_uninitialized_variables
  late final handleCustomMessage;

  late StreamSubscription<String> _jwtSubscription;

  @override
  void onInit() async {
    super.onInit();

    _jwtSubscription = securedController.jwt.listen((value) {
      if (value == accessToken) {
        return;
      }
      accessToken = value;

      if (value == '' && initDone) {
        socket.disconnect();
        return;
      }

      if (!initDone) {
        init();
        initDone = true;
      } else {
        var isConnected = checkIfSocketIsConnected();
        if (!isConnected) {
          reconnectSocket();
        }
      }
    });
  }

  @override
  void onClose() {
    _jwtSubscription.cancel();
    super.onClose();
  }

  void clearSocket() {
    socket.clearListeners();
    socket.disconnect();
    initDone = false;
  }

  void setCustomMessageHandler(handler) {
    handleCustomMessage = handler;
  }

  void reconnectSocket() {
    // ignore: unnecessary_null_comparison
    if (accessToken == '' || socket == null) {
      return;
    }

    try {
      socket.clearListeners();
      socket.disconnect();
      init();
    } catch (e) {
      print(
        'Could not disconnect and connect socket: ${accountController.account.value.email} -> $e',
      );
    }
  }

  bool checkIfSocketIsConnected() {
    if (!initDone) {
      return false;
    }
    // ignore: unnecessary_null_comparison
    return socket == null ? false : socket.connected;
  }

  init() {
    socket = IO.io(
      FlutterConfig.get('WS_SERVER_URL'),
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNewConnection()
          .disableAutoConnect()
          .setExtraHeaders({"token": accessToken})
          .build(),
    );

    // ignore: unnecessary_null_comparison
    if (socket == null) {
      return;
    }

    socket.connect();

    socket.on('connect', handleConnect);
    socket.on('message', handleMessage);
    socket.on('error', handleError);
    socket.on('disconnect', handleDisconnect);
  }

  void handleConnect(_) {
    print('Connected to socket: ${accountController.account.value.email}');
  }

  void handleMessage(data) {
    var decodedData = jsonDecode(data);
    if (decodedData["custom"] == null || decodedData["type"] == null) {
      return;
    }

    var messageType = CustomMessages.values.firstWhere(
      (element) =>
          element.toString() == 'CustomMessages.${decodedData["type"]}',
    );

    handleCustomMessage(messageType, decodedData["message"]);
  }

  void handleError(error) {
    print(
      'Could not connect to socket: ${accountController.account.value.email} -> $error',
    );
  }

  void handleDisconnect(_) {
    print('disconnect: Disconnected from socket');
  }
}
