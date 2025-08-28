import 'dart:convert';

import 'package:mazadi/core/repositories/base.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/flash.dart';
import '../models/auction.dart';
import '../models/location.dart';
import '../services/image_compress.dart';

enum AuctionsSortBy {
  newest,
  oldest,
  priceAsc,
  priceDesc,
}

class AuctionRepository {
  final dio = Get.find<Api>();
  final imageCompressService = Get.find<ImageCompressService>();
  final flashController = Get.find<FlashController>();

  Future<Auction?> loadDetails(String auctionId) async {
    try {
      var response = await dio.api.get('/auction/details/$auctionId');
      return Auction.fromJSON(response.data);
    } catch (error, stackTrace) {
      print('Error getting auction details: $error $stackTrace');
      return null;
    }
  }

  Future<AuctionTranslationResult?> translateDetails(
      String auctionId, String lang) async {
    try {
      var response = await dio.api.get('/auction/translate/$auctionId/$lang');
      return AuctionTranslationResult.fromJSON(response.data);
    } catch (error, stackTrace) {
      print('Error translating auction details: $error $stackTrace');
      return null;
    }
  }

  Future<List<Location>> loadAuctionLocations() async {
    try {
      var response = await dio.api.get('/location/all');
      return List<Location>.from(
        response.data.map(
          (el) => Location.fromJSON(el),
        ),
      );
    } catch (error) {
      print('Error getting locations: $error');
      return [];
    }
  }

  Future<bool> delete(String auctionId) async {
    try {
      await dio.api.delete('/auction/$auctionId');
      return true;
    } catch (error) {
      print('Error removing auction: $error');
      return false;
    }
  }

  Future<List<Auction>> loadRecommendations([
    int page = 0,
    int perPage = 10,
  ]) async {
    try {
      var response = await dio.api.post('/auction-similarities', data: {
        "page": page,
        "perPage": perPage,
      });
      return List<Auction>.from(
        response.data.map(
          (el) => Auction.fromJSON(el),
        ),
      );
    } catch (error, stackTrace) {
      print('Error getting recommendations: $error, $stackTrace');
      return [];
    }
  }

  Future<List<Auction>> loadByProximity(LatLng latlng, String mainCategoryId,
      [int distance = 10]) async {
    try {
      var response = await dio.api.get(
        '/auction/byLocationProximity/${latlng.latitude}/${latlng.longitude}/$mainCategoryId/$distance',
      );

      return List<Auction>.from(
        response.data.map(
          (el) => Auction.fromJSON(el),
        ),
      );
    } catch (error) {
      print('Error getting auctions by proximity: $error');
      return [];
    }
  }

  Future<bool> promote(String auctionId) async {
    try {
      await dio.api.put('/auction/promote/$auctionId');
      return true;
    } catch (error) {
      print('Error promoting auction: $error');
      return false;
    }
  }

  Future<List<Auction>> loadForAccount(
    String status, [
    int page = 0,
    int pageSize = 10,
    String query = '',
    AuctionsSortBy? sortBy = AuctionsSortBy.oldest,
  ]) async {
    try {
      String orderBy;
      String orderDirection;

      switch (sortBy) {
        case AuctionsSortBy.newest:
          orderBy = 'createdAt';
          orderDirection = 'desc';
        case AuctionsSortBy.oldest:
          orderBy = 'createdAt';
          orderDirection = 'asc';
        case AuctionsSortBy.priceDesc:
          orderBy = 'lastPrice';
          orderDirection = 'desc';
        case AuctionsSortBy.priceAsc:
          orderBy = 'lastPrice';
          orderDirection = 'asc';
        case null:
          orderBy = 'createdAt';
          orderDirection = 'desc';
      }

      if (status.contains('bid')) {
        var response = await dio.api
            .post('/auction/byBid/${status.replaceAll('bid-', '')}', data: {
          "page": page,
          "perPage": pageSize,
          "query": query,
          "orderBy": orderBy,
          "orderDirection": orderDirection,
        });
        return List<Auction>.from(
          response.data.map(
            (el) => Auction.fromJSON(el),
          ),
        );
      }

      var response = await dio.api.post('/auction/all/account/$status', data: {
        "page": page,
        "perPage": pageSize,
        "query": query,
        "orderBy": orderBy,
        "orderDirection": orderDirection,
      });
      return List<Auction>.from(
        response.data.map(
          (el) => Auction.fromJSON(el),
        ),
      );
    } catch (error, stackTrace) {
      print('Error getting auctions for account: $error, $stackTrace');
      return [];
    }
  }

  Future<List<Auction>> search(String query,
      [int page = 0, int perPage = 10]) async {
    try {
      var response = await dio.api.get('/auction/search/$query/$page/$perPage');
      return List<Auction>.from(
        response.data.map(
          (el) => Auction.fromJSON(el),
        ),
      );
    } catch (error, stackTrace) {
      print('Error searching auctions: $error $stackTrace');
      return [];
    }
  }

  Future<List<Auction>?> loadLatestAuctions() async {
    try {
      var response = await dio.api.get('/auction/latest');
      return (response.data as List)
          .map((auction) => Auction.fromJSON(auction))
          .toList();
    } catch (error, stackTrace) {
      print('Error getting latest auctions: $error $stackTrace');
      return null;
    }
  }

  Future<int> countFilter(
    List<String> categories,
    List<String> subCategories,
    List<String> locations,
    bool activeOnly, [
    bool includeMyAuctions = true,
    int? minPrice = 0,
    int? maxPrice = 0,
  ]) async {
    try {
      var response = await dio.api.post('/auction/filter/count', data: {
        "categories": jsonEncode(categories),
        "subCategories": jsonEncode(subCategories),
        "locationIds": jsonEncode(locations),
        "activeOnly": activeOnly,
        "includeMyAuctions": includeMyAuctions,
        "minPrice": minPrice,
        "maxPrice": maxPrice,
      });

      return int.parse(response.data['count'].toString());
    } catch (error) {
      print('Error counting filtered auctions: $error');
      return 0;
    }
  }

  Future<List<Auction>> loadActiveForAccount(
    String accountId, [
    int page = 0,
    int pageSize = 10,
    String query = '',
    AuctionsSortBy? sortBy = AuctionsSortBy.oldest,
  ]) async {
    try {
      String orderBy;
      String orderDirection;

      switch (sortBy) {
        case AuctionsSortBy.newest:
          orderBy = 'createdAt';
          orderDirection = 'desc';
        case AuctionsSortBy.oldest:
          orderBy = 'createdAt';
          orderDirection = 'asc';
        case AuctionsSortBy.priceDesc:
          orderBy = 'lastPrice';
          orderDirection = 'desc';
        case AuctionsSortBy.priceAsc:
          orderBy = 'lastPrice';
          orderDirection = 'asc';
        case null:
          orderBy = 'createdAt';
          orderDirection = 'desc';
      }

      var response =
          await dio.api.post('/auction/byAccount/active/$accountId', data: {
        "page": page,
        "perPage": pageSize,
        "query": query,
        "orderBy": orderBy,
        "orderDirection": orderDirection,
      });
      return List<Auction>.from(
        response.data.map(
          (el) => Auction.fromJSON(el),
        ),
      );
    } catch (error) {
      print('Error getting active auctions for account: $error');
      return [];
    }
  }

  Future<List<Auction>> loadFilteredAuctions(
    List<String> categories,
    List<String> subCategories,
    List<String> locations,
    bool activeOnly,
    int page,
    int pageSize, [
    String query = '',
    AuctionsSortBy? sortBy = AuctionsSortBy.oldest,
    bool includeMyAuctions = true,
    int? minPrice = 0,
    int? maxPrice = 0,
    bool? started = true,
  ]) async {
    try {
      String orderBy;
      String orderDirection;

      switch (sortBy) {
        case AuctionsSortBy.newest:
          orderBy = 'createdAt';
          orderDirection = 'desc';
        case AuctionsSortBy.oldest:
          orderBy = 'createdAt';
          orderDirection = 'asc';
        case AuctionsSortBy.priceDesc:
          orderBy = 'lastPrice';
          orderDirection = 'desc';
        case AuctionsSortBy.priceAsc:
          orderBy = 'lastPrice';
          orderDirection = 'asc';
        case null:
          orderBy = 'createdAt';
          orderDirection = 'desc';
      }

      var response = await dio.api.post('/auction/filter/auctions', data: {
        "categories": jsonEncode(categories),
        "subCategories": jsonEncode(subCategories),
        "locationIds": jsonEncode(locations),
        "page": page,
        "perPage": pageSize,
        "activeOnly": activeOnly,
        "query": query,
        "orderBy": orderBy,
        "orderDirection": orderDirection,
        'includeMyAuctions': includeMyAuctions,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'started': started,
      });

      return List<Auction>.from(
        response.data.map(
          (el) => Auction.fromJSON(el),
        ),
      );
    } catch (error) {
      print('Error loading filtered auctions: $error');
      return [];
    }
  }

  Future<Auction?> update(CreateUpdateAuctionParams params) async {
    try {
      var data = await generateFormDataForCreateOrUpdate(params);
      var result = await dio.api.put('/auction/${params.id}', data: data);
      return Auction.fromJSON(result.data);
    } catch (error) {
      if (error is DioException) {
        var response = error.response?.data.toString() ?? '';

        if (response.contains('TOO_MANY')) {
          flashController.showMessageFlash(
              tr('create_auction.repository.too_many_assets'));
          return null;
        }

        if (response.contains('ASSET_TOO_BIG')) {
          flashController
              .showMessageFlash(tr('create_auction.repository.asset_too_big'));
          return null;
        }

        if (response.contains('ASSET_NOT_SUPPORTED')) {
          flashController.showMessageFlash(
              tr('create_auction.repository.asset_not_supported'));
          return null;
        }
      }

      flashController
          .showMessageFlash(tr('create_auction.repository.could_not_create'));
      return null;
    }
  }

  Future<Auction?> create(CreateUpdateAuctionParams params) async {
    try {
      var data = await generateFormDataForCreateOrUpdate(params);
      var result = await dio.api.post('/auction', data: data);
      return Auction.fromJSON(result.data);
    } catch (error) {
      if (error is DioException) {
        var response = error.response?.data.toString() ?? '';

        if (response.contains('TOO_MANY')) {
          flashController.showMessageFlash(
              tr('create_auction.repository.too_many_assets'));
          return null;
        }

        if (response.contains('ASSET_TOO_BIG')) {
          flashController
              .showMessageFlash(tr('create_auction.repository.asset_too_big'));
          return null;
        }

        if (response.contains('ASSET_NOT_SUPPORTED')) {
          flashController.showMessageFlash(
              tr('create_auction.repository.asset_not_supported'));
          return null;
        }
      }

      flashController
          .showMessageFlash(tr('create_auction.repository.could_not_create'));
      return null;
    }
  }

  Future<dio_lib.FormData> generateFormDataForCreateOrUpdate(
    CreateUpdateAuctionParams params,
  ) async {
    var galleryAssets = params.galleryAssets ?? [];
    var cameraAssets = params.cameraAssets ?? [];

    var files = galleryAssets.map((asset) async {
      var compressed =
          await imageCompressService.compressFileByPath(asset.path);
      return dio_lib.MultipartFile.fromFileSync(
        compressed.path,
        filename: asset.name,
      );
    }).toList();

    var cameraFiles = cameraAssets.map((asset) async {
      var compressed = await imageCompressService.compressFile(asset);
      return dio_lib.MultipartFile.fromFileSync(
        compressed.path,
        filename: asset.name,
      );
    }).toList();

    files.addAll(cameraFiles);

    var compressedFiles = await Future.wait(files);

    var data = dio_lib.FormData.fromMap({
      'latLng': jsonEncode(params.latLng),
      'location': params.location,
      'description': params.description ?? '',
      'hasCustomStartingPrice': params.hasCustomStartingPrice,
      'files': compressedFiles,
      'price': params.price,
      'startAt': params.startAt?.toIso8601String(),
      'expiresAt': params.expiresAt?.toIso8601String(),
      'title': params.title,
      // ignore: prefer_is_empty
      'assetsToKeep': params.assetsToKeep?.length != 0
          ? jsonEncode(params.assetsToKeep ?? [])
          : null,
      'mainCategoryId': params.mainCategoryId,
      'subCategoryId': params.subCategoryId,
      'condition': params.condition,
    });
    return data;
  }
}

class AuctionTranslationResult {
  final String? title;
  final String? description;

  AuctionTranslationResult({
    this.title,
    this.description,
  });

  static AuctionTranslationResult fromJSON(Map<String, dynamic> data) {
    return AuctionTranslationResult(
      title: data['title'],
      description: data['description'],
    );
  }
}
