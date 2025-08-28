import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'account.dart';

class Bid {
  String? id;
  Account? bidder;
  LatLng? location;
  String? locationPretty;
  String? description;
  bool? isRejected;
  String? rejectionReason;
  bool? isAccepted;
  double? price;
  DateTime? biddedAt;

  Bid({
    this.id,
    this.bidder,
    this.location,
    this.description,
    this.isRejected,
    this.locationPretty,
    this.rejectionReason,
    this.isAccepted,
    this.biddedAt,
    this.price,
  });

  static Bid fromJSON(dynamic data) {
    var bidder =
        data['bidder'] != null ? Account.fromJSON(data['bidder']) : null;

    var locationLat = data['locationLat'] != null
        ? double.parse(data['locationLat'].toString())
        : null;
    var locationLong = data['locationLong'] != null
        ? double.parse(data['locationLong'].toString())
        : null;
    var locationLatLng = locationLat != null && locationLong != null
        ? LatLng(locationLat, locationLong)
        : null;

    return Bid(
      id: data['id'],
      bidder: bidder,
      description: data['description'],
      price:
          data['price'] != null ? double.parse(data['price'].toString()) : 0.0,
      isRejected: data['isRejected'],
      locationPretty: data['locationPretty'] ?? '',
      rejectionReason: data['rejectionReason'],
      isAccepted: data['isAccepted'],
      biddedAt: DateTime.parse(data['createdAt']),
      location: locationLatLng,
    );
  }
}
