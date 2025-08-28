// ignore_for_file: non_constant_identifier_names

import 'package:mazadi/core/models/asset.dart';
import 'package:mazadi/core/models/review.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'auction.dart';
import 'filter.dart';

class Account {
  String id;
  String? name;
  String email;
  String picture;
  bool isAnonymous;
  String? deviceFCMToken;
  bool acceptedTermsAndCondition;
  int? activeAuctionsCount;

  List<Auction> auctions;
  List<Review> reviews;
  List<String>? blockedAccounts;

  AccountMetadata? meta;
  AccountNotifications? allowedNotifications;

  int? followersCount;
  int? followingCount;

  int? reviewsCount;
  double? reviewsAverage;

  bool introDone;
  bool introSkipped;

  int coins;

  bool categoriesSetupDone;
  List<String> preferredCategoriesIds;

  List<String>? followedByAccountsIds;
  List<String>? followingAccountsIds;
  List<FilterItem>? filters;

  LatLng? locationLatLng;
  String? locationPretty;

  DateTime? createdAt;
  DateTime? updatedAt;

  Account({
    this.id = '',
    this.email = '',
    this.name = '',
    this.picture = '',
    this.isAnonymous = false,
    this.locationLatLng,
    this.locationPretty,
    this.acceptedTermsAndCondition = false,
    this.deviceFCMToken = '',
    this.introDone = false,
    this.introSkipped = false,
    this.auctions = const [],
    this.reviews = const [],
    this.blockedAccounts = const [],
    this.followersCount = 0,
    this.followingCount = 0,
    this.coins = 0,
    this.activeAuctionsCount = 0,
    this.followedByAccountsIds = const [],
    this.followingAccountsIds = const [],
    this.filters = const [],
    this.allowedNotifications,
    this.reviewsAverage,
    this.reviewsCount = 0,
    this.categoriesSetupDone = false,
    this.preferredCategoriesIds = const [],
    this.meta,
    this.createdAt,
    this.updatedAt,
  });

  static Account fromJSON(dynamic data) {
    var serverBaseUrl = FlutterConfig.get('SERVER_URL');
    var picture =
        data['asset'] != null ? Asset.fromJSON(data['asset']) : data['picture'];

    var locationLat = data['locationLat'];
    var locationLong = data['locationLong'];
    var locationLatLng = locationLat != null && locationLong != null
        ? LatLng(locationLat, locationLong)
        : null;

    return Account(
      id: data['id'],
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isAnonymous: data['isAnonymous'] ?? false,
      picture: picture is String
          ? picture
          : (picture.id != null
                  ? '$serverBaseUrl/assets/${picture.path}'
                  : picture) ??
              '',
      reviewsAverage: data['reviewsAverage'] != null
          ? double.parse(data['reviewsAverage'].toString())
          : null,
      reviewsCount: data['reviewsCount'] != null
          ? int.parse(data['reviewsCount'].toString())
          : 0,
      categoriesSetupDone: data['categoriesSetupDone'] ?? false,
      preferredCategoriesIds: data['preferredCategoriesIds'] != null
          ? List<String>.from(data['preferredCategoriesIds'])
          : [],
      locationLatLng: locationLatLng,
      locationPretty: data['locationPretty'],
      coins: data['coins'] ?? 0,
      deviceFCMToken: data['deviceFCMToken'] ?? '',
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      introDone: data['introDone'] ?? false,
      introSkipped: data['introSkipped'] ?? false,
      acceptedTermsAndCondition: data['acceptedTermsAndCondition'] ?? false,
      meta: data['meta'] != null
          ? AccountMetadata.fromJSON(data['meta'])
          : AccountMetadata(),
      activeAuctionsCount: data['activeAuctionsCount'] != null
          ? int.tryParse(data['activeAuctionsCount'].toString())
          : 0,
      blockedAccounts: data['blockedAccounts'] != null
          ? List<String>.from(data['blockedAccounts'])
          : [],
      followedByAccountsIds: data['followedByAccountsIds'] != null
          ? List<String>.from(data['followedByAccountsIds'])
          : [],
      followingAccountsIds: data['followingAccountsIds'] != null
          ? List<String>.from(data['followingAccountsIds'])
          : [],
      auctions: data['auctions'] != null
          ? data['auctions'].map<Auction>((el) => Auction.fromJSON(el)).toList()
          : [],
      reviews: data['receivedReviews'] != null
          ? data['receivedReviews']
              .map<Review>((el) => Review.fromJSON(el))
              .toList()
          : [],
      filters: data['filters'] != null
          ? data['filters']
              .map<FilterItem>((el) => FilterItem.fromJSON(el))
              .toList()
          : [],
      allowedNotifications: data['allowedNotifications'] != null
          ? AccountNotifications.fromJSON(data['allowedNotifications'])
          : AccountNotifications(),
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  Map toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'picture': picture,
      };
}

class AccountNotifications {
  bool NEW_BID_ON_AUCTION;
  bool AUCTION_UPDATED;
  bool BID_REMOVED_ON_AUCTION;
  bool BID_ACCEPTED_ON_AUCTION;
  bool BID_REJECTED_ON_AUCTION;
  bool REVIEW_RECEIVED;
  bool NEW_MESSAGE;
  bool SYSTEM;
  bool SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION;
  bool BID_WAS_SEEN;
  bool NEW_FOLLOWER;
  bool AUCTION_FROM_FAVOURITES_HAS_BID;
  bool NEW_AUCTION_FROM_FOLLOWING;
  bool AUCTION_ADDED_TO_FAVOURITES;
  bool FAVOURITE_AUCTION_PRICE_CHANGE;
  bool MY_AUCTION_STARTED;
  bool AUCTION_FROM_FAVOURITES_STARTED;

  AccountNotifications({
    this.NEW_BID_ON_AUCTION = true,
    this.AUCTION_UPDATED = true,
    this.BID_REMOVED_ON_AUCTION = true,
    this.BID_ACCEPTED_ON_AUCTION = true,
    this.BID_REJECTED_ON_AUCTION = true,
    this.REVIEW_RECEIVED = true,
    this.NEW_MESSAGE = true,
    this.SYSTEM = true,
    this.SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION = true,
    this.BID_WAS_SEEN = true,
    this.NEW_FOLLOWER = true,
    this.AUCTION_FROM_FAVOURITES_HAS_BID = true,
    this.NEW_AUCTION_FROM_FOLLOWING = true,
    this.AUCTION_ADDED_TO_FAVOURITES = true,
    this.FAVOURITE_AUCTION_PRICE_CHANGE = true,
    this.MY_AUCTION_STARTED = true,
    this.AUCTION_FROM_FAVOURITES_STARTED = true,
  });

  static AccountNotifications fromJSON(dynamic data) {
    return AccountNotifications(
      NEW_BID_ON_AUCTION: data['NEW_BID_ON_AUCTION'] ?? true,
      AUCTION_UPDATED: data['AUCTION_UPDATED'] ?? true,
      BID_REMOVED_ON_AUCTION: data['BID_REMOVED_ON_AUCTION'] ?? true,
      BID_ACCEPTED_ON_AUCTION: data['BID_ACCEPTED_ON_AUCTION'] ?? true,
      BID_REJECTED_ON_AUCTION: data['BID_REJECTED_ON_AUCTION'] ?? true,
      REVIEW_RECEIVED: data['REVIEW_RECEIVED'] ?? true,
      NEW_MESSAGE: data['NEW_MESSAGE'] ?? true,
      SYSTEM: data['SYSTEM'] ?? true,
      SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION:
          data['SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION'] ?? true,
      BID_WAS_SEEN: data['BID_WAS_SEEN'] ?? true,
      NEW_FOLLOWER: data['NEW_FOLLOWER'] ?? true,
      AUCTION_FROM_FAVOURITES_HAS_BID:
          data['AUCTION_FROM_FAVOURITES_HAS_BID'] ?? true,
      NEW_AUCTION_FROM_FOLLOWING: data['NEW_AUCTION_FROM_FOLLOWING'] ?? true,
      AUCTION_ADDED_TO_FAVOURITES: data['AUCTION_ADDED_TO_FAVOURITES'] ?? true,
      FAVOURITE_AUCTION_PRICE_CHANGE:
          data['FAVOURITE_AUCTION_PRICE_CHANGE'] ?? true,
      MY_AUCTION_STARTED: data['MY_AUCTION_STARTED'] ?? true,
      AUCTION_FROM_FAVOURITES_STARTED:
          data['AUCTION_FROM_FAVOURITES_STARTED'] ?? true,
    );
  }

  Object asObject() {
    return {
      'NEW_BID_ON_AUCTION': NEW_BID_ON_AUCTION,
      'AUCTION_UPDATED': AUCTION_UPDATED,
      'BID_REMOVED_ON_AUCTION': BID_REMOVED_ON_AUCTION,
      'BID_ACCEPTED_ON_AUCTION': BID_ACCEPTED_ON_AUCTION,
      'BID_REJECTED_ON_AUCTION': BID_REJECTED_ON_AUCTION,
      'REVIEW_RECEIVED': REVIEW_RECEIVED,
      'NEW_MESSAGE': NEW_MESSAGE,
      'SYSTEM': SYSTEM,
      'SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION':
          SOMEONE_ELSE_ADDED_BID_TO_SAME_AUCTION,
      'BID_WAS_SEEN': BID_WAS_SEEN,
      'NEW_FOLLOWER': NEW_FOLLOWER,
      'AUCTION_FROM_FAVOURITES_HAS_BID': AUCTION_FROM_FAVOURITES_HAS_BID,
      'NEW_AUCTION_FROM_FOLLOWING': NEW_AUCTION_FROM_FOLLOWING,
      'AUCTION_ADDED_TO_FAVOURITES': AUCTION_ADDED_TO_FAVOURITES,
      'FAVOURITE_AUCTION_PRICE_CHANGE': FAVOURITE_AUCTION_PRICE_CHANGE,
      'MY_AUCTION_STARTED': MY_AUCTION_STARTED,
      'AUCTION_FROM_FAVOURITES_STARTED': AUCTION_FROM_FAVOURITES_STARTED,
    };
  }
}

class AccountMetadata {
  DateTime? lastSignInTime;
  String? appLanguage;

  AccountMetadata({
    this.lastSignInTime,
    this.appLanguage,
  });

  static AccountMetadata fromJSON(dynamic data) {
    try {
      var lastSignInTime = data['lastSignInTime'] != null
          ? DateTime.parse(data['lastSignInTime'])
          : null;
      return AccountMetadata(
        lastSignInTime: lastSignInTime,
        appLanguage: data['appLanguage'],
      );
    } catch (e) {
      return AccountMetadata(appLanguage: data['appLanguage']);
    }
  }

  Object asObject() {
    return {
      'lastSignInTime': lastSignInTime,
      'appLanguage': appLanguage,
    };
  }
}
