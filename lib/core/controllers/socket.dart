import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';

import '../services/socket.dart';
import 'account.dart';

enum SocketEvents {
  joinRoom,
}

class SocketController extends GetxController {
  final socketService = Get.find<SocketService>();
  final accountController = Get.find<AccountController>();

  late Timer _connectivityCheckTimer;
  Map<CustomMessages, Function> _handlers = {};

  RxList<String> connectedAccounts = RxList<String>();

  @override
  void onInit() {
    super.onInit();
    socketService.setCustomMessageHandler(handleSocketCustomMessage);

    _connectivityCheckTimer =
        Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!socketService.checkIfSocketIsConnected()) {
        socketService.reconnectSocket();
      }
    });

    for (var value in CustomMessages.values) {
      _handlers[value] = () {};
    }
  }

  @override
  void onClose() {
    _connectivityCheckTimer.cancel();
    _handlers.clear();
    super.onClose();
  }

  void setHandler(CustomMessages messageType, Function handler) {
    _handlers[messageType] = handler;
  }

  void emitEvent(SocketEvents event, [dynamic data]) {
    try {
      // ignore: unnecessary_null_comparison
      if (socketService.socket == null) {
        return;
      }

      socketService.socket.emit(EnumToString.convertToString(event), data);
    } catch (error) {
      print('Coult not emit socket event $event');
    }
  }

  void handleSocketCustomMessage(
    CustomMessages messageType,
    dynamic message,
  ) {
    if (_handlers[messageType] != null) {
      try {
        _handlers[messageType]!(message);
      } catch (error) {
        print('Could not handle socket message $messageType');
      }
    }

    switch (messageType) {
      case CustomMessages.bidAccepted:
        accountController.acceptedBidsCount.value++;
      case CustomMessages.bidRejected:
        accountController.rejectedBidsCount.value++;
      case CustomMessages.allConnectedAccounts:
        if (message != null) {
          connectedAccounts.value = List<String>.from(message);
        }
      case CustomMessages.newConnectedAccount:
        if (message != null) {
          var alreadyConnected = connectedAccounts.firstWhereOrNull(
            (element) => element == message,
          );
          if (alreadyConnected == null) {
            connectedAccounts.add(message);
          }
        }
      case CustomMessages.accountDisconnected:
        if (message != null) {
          connectedAccounts.remove(message);
        }
      case CustomMessages.coinsUpdated:
        try {
          accountController.updateCoins(message['coins']);
        } catch (error) {
          print('Could not update coins $message');
        }
      default:
        break;
    }
  }
}
