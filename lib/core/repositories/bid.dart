import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;

import '../controllers/flash.dart';
import '../models/bid.dart';
import '../services/image_compress.dart';
import 'base.dart';

class BidRepository {
  var dio = Get.find<Api>();
  var flashController = Get.find<FlashController>();
  var imageCompressService = Get.find<ImageCompressService>();

  Future<bool> delete(String bidId) async {
    try {
      await dio.api.delete('/bid/$bidId');
      return true;
    } catch (error) {
      print('Error removing bid: $error');
      return false;
    }
  }

  Future<bool> markBidsFromAuctionAsSeen(String auctionId) async {
    try {
      await dio.api.put(
        '/bid/markBidsAsSeen/$auctionId',
      );

      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> update(
    String bidId, [
    String? rejectionReason,
    bool? isRejected,
    bool? isAccepted,
  ]) async {
    if (isRejected == null && isAccepted == null) {
      throw Exception('You must provide either isRejected or isAccepted');
    }

    try {
      await dio.api.put(
        '/bid/$bidId',
        data: jsonEncode(
          {
            "isAccepted": isAccepted,
            "isRejected": isRejected,
            "rejectionReason": rejectionReason,
          },
        ),
      );

      return true;
    } catch (error) {
      flashController.showMessageFlash(
        'Could not update bid. Please try again.',
      );
      return false;
    }
  }

  Future<Bid?> create(String auctionId, CreateBidParams params) async {
    var description = params.description!.replaceAll('\n\n\n\n\n\n', '\n');
    try {
      var result = await dio.api.post('/bid/$auctionId', data: {
        'latLng': jsonEncode(params.latLng),
        'location': params.location,
        'description': description,
        'price': params.price,
      });
      return Bid.fromJSON(result.data);
    } catch (error) {
      print('Error creating bid: $error');
      flashController
          .showMessageFlash('Could not create bid. Please try again.');
      return null;
    }
  }
}

class CreateBidParams {
  final String? description;
  final double price;
  google_map.LatLng latLng;
  final String location;

  CreateBidParams({
    this.description = '',
    required this.price,
    required this.latLng,
    required this.location,
  });
}
