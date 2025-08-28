import 'package:mazadi/core/controllers/image_picker.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
// ignore: library_prefixes
import './review.dart' as ReviewModel;

import 'account.dart';
import 'asset.dart';
import 'bid.dart';

var uuid = const Uuid();

enum AuctionProductCondition { newProduct, used }

class Auction {
  String id;
  String title;
  String description;
  AuctionProductCondition condition;
  Account? auctioneer;

  LatLng? location;
  String? locationPretty;
  List<Asset>? assets;
  List<Rx<Bid>> bids;
  List<ReviewModel.Review>? reviews;
  int? views;

  String? acceptedBidId;
  DateTime? acceptedBidAt;
  int bidsCount;

  bool? hasCustomStartingPrice;
  double startingPrice;
  double? lastPrice;

  int? likesCount;

  String mainCategoryId;
  String subCategoryId;

  DateTime? startAt;
  DateTime? startedAt;

  DateTime createdAt;
  DateTime? updatedAt;
  DateTime? expiresAt;
  DateTime? promotedAt;
  bool isActive;

  Auction({
    String? id,
    required this.auctioneer,
    this.description = '',
    this.title = '',
    this.condition = AuctionProductCondition.newProduct,
    this.location,
    this.locationPretty,
    this.assets,
    this.bids = const [],
    this.reviews,
    this.likesCount = 0,
    this.views,
    this.acceptedBidId,
    this.acceptedBidAt,
    this.bidsCount = 0,
    this.hasCustomStartingPrice,
    this.startingPrice = 0,
    this.lastPrice,
    required this.mainCategoryId,
    required this.subCategoryId,
    required this.createdAt,
    this.expiresAt,
    this.updatedAt,
    this.promotedAt,
    this.startedAt,
    this.startAt,
    this.isActive = true,
  }) : id = id ?? uuid.v4();

  static Auction fromJSON(dynamic data) {
    var auctioneer =
        data['account'] != null ? Account.fromJSON(data['account']) : null;
    var locationLat = data['locationLat'];
    var locationLong = data['locationLong'];
    var locationLatLng = locationLat != null && locationLong != null
        ? LatLng(double.parse(locationLat.toString()),
            double.parse(locationLong.toString()))
        : null;

    // ignore: prefer_null_aware_operators
    var reviews = data['reviews'] != null
        ? data['reviews']
            .map<ReviewModel.Review>(
                (review) => ReviewModel.Review.fromJSON(review))
            .toList()
        : null;

    // It is active only if the auction expiresAt is greater than the current time
    var isActive = data['expiresAt'] != null
        ? DateTime.parse(data['expiresAt']).isAfter(DateTime.now())
        : true;

    return Auction(
      id: data['id'],
      title: data['title'],
      auctioneer: auctioneer,
      reviews: reviews,
      isActive: isActive,
      condition: data['isNewItem']?.toString() == 'true'
          ? AuctionProductCondition.newProduct
          : AuctionProductCondition.used,
      description: data['description'] ?? '',
      locationPretty: data['locationPretty'] ?? '',
      location: locationLatLng,
      startingPrice: data['startingPrice'] != null
          ? double.parse(data['startingPrice'].toString())
          : 0,
      lastPrice: data['lastPrice'] != null
          ? double.parse(data['lastPrice'].toString())
          : 0,
      likesCount: data['likesCount'] != null
          ? int.parse(data['likesCount'].toString())
          : 0,
      mainCategoryId: data['mainCategoryId'],
      subCategoryId: data['subCategoryId'],
      acceptedBidId: data['acceptedBidId'],
      bidsCount: data['bidsCount'] ?? 0,
      views: data['views'] != null ? int.parse(data['views'].toString()) : null,
      hasCustomStartingPrice: data['hasCustomStartingPrice'] ?? false,
      assets: data['auctionAssets'] != null
          ? data['auctionAssets']
              .map<Asset>((asset) => Asset.fromJSON(asset))
              .toList()
          : [],
      bids: data['bids'] != null
          ? data['bids'].map<Rx<Bid>>((bid) => Bid.fromJSON(bid).obs).toList()
          : [],
      acceptedBidAt: data['acceptedBidAt'] != null
          ? DateTime.parse(data['acceptedBidAt'])
          : null,
      startAt: data['startAt'] != null ? DateTime.parse(data['startAt']) : null,
      startedAt:
          data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null,
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      promotedAt: data['promotedAt'] != null
          ? DateTime.parse(data['promotedAt'])
          : null,
      expiresAt:
          data['expiresAt'] != null ? DateTime.parse(data['expiresAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'auctionAssets': assets?.map((asset) => asset.toJson()).toList(),
      'acceptedBidId': acceptedBidId,
      'acceptedBidAt': acceptedBidAt,
      'bidsCount': bidsCount,
      'hasCustomStartingPrice': hasCustomStartingPrice,
      'startingPrice': startingPrice,
      'lastPrice': lastPrice,
      'mainCategoryId': mainCategoryId,
      'subCategoryId': subCategoryId,
      'isActive': isActive,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt?.toString(),
    };
  }
}

class CreateUpdateAuctionParams {
  String? id;
  String title;
  String location;
  String? description;
  bool hasCustomStartingPrice;
  String mainCategoryId;
  String subCategoryId;
  double price;
  String condition;
  List<String>? assetsToKeep;
  DateTime? startAt;
  DateTime? expiresAt;

  google_map.LatLng latLng;
  List<AssetEntityPath>? galleryAssets;
  List<XFile>? cameraAssets;

  CreateUpdateAuctionParams({
    this.id,
    required this.title,
    required this.location,
    required this.price,
    required this.hasCustomStartingPrice,
    required this.latLng,
    required this.mainCategoryId,
    required this.subCategoryId,
    this.description,
    this.startAt,
    this.expiresAt,
    this.galleryAssets,
    this.cameraAssets,
    this.assetsToKeep,
    this.condition = 'new',
  });
}
