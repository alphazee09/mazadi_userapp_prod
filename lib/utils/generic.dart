import 'package:easy_localization/easy_localization.dart';

import '../core/models/account.dart';
import '../core/models/review.dart';
import 'dart:math';

class GenericUtils {
  static String capitalizeString(String str) {
    return str[0].toUpperCase() + str.substring(1);
  }

  static bool textContainsUrl(String text) {
    final urlPattern = RegExp(r'(http[s]?://|www\.)[^\s]+');
    return urlPattern.hasMatch(text);
  }

  static String extractFirstUrlFromText(String text) {
    final urlPattern = RegExp(r'(http[s]?://|www\.)[^\s]+');
    final match = urlPattern.firstMatch(text);
    String url = match?.group(0) ?? '';
    return url.startsWith('http') ? url : 'https://$url';
  }

  static double calculateDistanceBetweenPoints(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    const int earthRadius = 6371; // Radius of the earth in kilometers

    double toRadians(double value) {
      return value * pi / 180;
    }

    double deltaLatitude = toRadians(endLatitude - startLatitude);
    double deltaLongitude = toRadians(endLongitude - startLongitude);

    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(toRadians(startLatitude)) *
            cos(toRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  static double computeReviewsAverage(List<Review> reviews) {
    if (reviews.isEmpty) {
      return 0.0;
    }

    var sum = 0.0;
    for (var review in reviews) {
      sum += review.stars;
    }

    return sum / reviews.length;
  }

  static String getFormattedDate(DateTime date, String locale) =>
      DateFormat('d MMM, h:mm a').format(date);

  static String generateNameForAccount(Account? acc) {
    var unknownValue = tr('generic.unknown');
    if (acc == null) {
      return unknownValue;
    }

    if (acc.name != null && acc.name != '') {
      return acc.name!;
    }

    if (acc.email != '') {
      var containsAt = acc.email.indexOf('@');
      if (containsAt != -1) {
        return acc.email.substring(0, containsAt);
      }
      return acc.email;
    }

    return unknownValue;
  }
}
