import 'package:get/get.dart';
import '../models/notification.dart';
import 'base.dart';

class NotificationRepository {
  var dio = Get.find<Api>();

  Future<int> getUnreadNotificationsCount() async {
    try {
      var response = await dio.api.get('/notification/unread');
      return response.data['unreadNotificationsCount'];
    } catch (error) {
      print('Coult not get unread notifications count: $error');
      return 0;
    }
  }

  Future<List<mazadiNotification>> loadForAccount([
    int page = 0,
    int perPage = 20,
  ]) async {
    try {
      var response = await dio.api.get('/notification/$page/$perPage');
      return List<mazadiNotification>.from(
        response.data.map(
          (el) => mazadiNotification.fromJSON(el),
        ),
      );
    } catch (error, stackTrace) {
      print('Coult not load notifications: $error, $stackTrace');
      return [];
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      await dio.api.put('/notification/$id');
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await dio.api.put('/notification');
      return true;
    } catch (error) {
      return false;
    }
  }
}
