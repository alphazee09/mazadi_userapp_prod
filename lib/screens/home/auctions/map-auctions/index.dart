import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/controllers/auction.dart';
import '../../../../core/controllers/flash.dart';
import '../../../../core/controllers/map_auctions.dart';
import '../../../../core/controllers/maps.dart';
import '../../../../core/models/auction.dart';
import '../../../../theme/extensions/base.dart';
import '../../../../widgets/common/info_card.dart';
import 'utils.dart';
import 'widgets/auction_marker.dart';
import 'widgets/bottom_sheet_auctions.dart';
import 'dialogs/location_not_available_dialog.dart';

import 'widgets/category_select_dropdown.dart';
import 'widgets/custom_marker.dart';
import 'widgets/location_searchbar.dart';

class MapAuctionsScreen extends StatefulWidget {
  const MapAuctionsScreen({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MapAuctionsScreenState createState() => _MapAuctionsScreenState();
}

class _MapAuctionsScreenState extends State<MapAuctionsScreen> {
  final mapAuctionsController = Get.find<MapAuctionsController>();
  final flashController = Get.find<FlashController>();
  final auctionsController = Get.find<AuctionController>();
  final mapsController = Get.find<MapsController>();

  GoogleMapController? _controller;
  Map<String, Marker> _markers = {};

  double _mapZoom = 14.0;
  bool _auctionsLoading = false;
  final List<Rx<Auction>> _loadedAuctions = [];
  final Map<LatLng, List<String>> _auctionsInLocation = {};

  late final CameraPosition _initialCameraPos = CameraPosition(
    target: mapAuctionsController.currentMapPosition.value,
    zoom: 14.0,
  );

  late StreamSubscription<String> _categoryListener;

  @override
  void initState() {
    super.initState();

    _categoryListener =
        mapAuctionsController.categoryToDisplayOnMap.listen((category) async {
      _markers = {};
      _auctionsInLocation.clear();
      _loadedAuctions.clear();
      await _loadAuctions();
    });

    _loadAuctions();
  }

  @override
  void dispose() {
    _categoryListener.cancel();
    super.dispose();
  }

  void _animateCameraToLocation(LatLng latLng) {
    mapAuctionsController.updateCurrentMapPosition(latLng);

    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 14),
      ),
    );
  }

  void _openBottomSheet(LatLng latLng) {
    var auctionIds = _auctionsInLocation[latLng];
    if (auctionIds == null || auctionIds.isEmpty) {
      return;
    }

    var auctions = _loadedAuctions.where((element) {
      return auctionIds.contains(element.value.id);
    }).toList();

    showModalBottomSheet(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            color:
                Theme.of(context).extension<CustomThemeFields>()!.background_1,
            child: Wrap(
              children: [
                MapBottomSheetAuctions(auctions: auctions),
              ],
            ),
          ),
        );
      },
    );
  }

  void showLoadedAuctionsFlash(int loadedAuctions, int existingAuctions) {
    if (loadedAuctions == 0) {
      if (existingAuctions != 0) {
        return;
      }

      flashController.showTransparendFlash(
        Text(
          'map_auctions.no_auction_loaded',
          textAlign: TextAlign.center,
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ).tr(),
        3,
      );
      return;
    }

    flashController.showTransparendFlash(
      Text(
        'map_auctions.auctions_loaded',
        style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
      ).tr(namedArgs: {'no': loadedAuctions.toString()}),
      3,
    );
  }

  Future<void> _loadAuctions([LatLng? latLng]) async {
    if (_auctionsLoading == true || _controller == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _auctionsLoading = true;
      });
    }

    int loadedAuctions = 0;
    var latLngToUse = latLng ?? mapAuctionsController.currentMapPosition.value;
    var auctions = await auctionsController.loadByProximity(
      latLngToUse,
      mapAuctionsController.categoryToDisplayOnMap.value,
    );

    for (var auction in auctions) {
      if (_loadedAuctions.any((element) => element.value.id == auction.id) ||
          auction.location == null) {
        continue;
      }

      loadedAuctions += 1;
      if (!_auctionsInLocation.containsKey(auction.location)) {
        _auctionsInLocation[auction.location!] = [auction.id];
      } else {
        _auctionsInLocation[auction.location!]!.add(auction.id);
      }

      _loadedAuctions.add(auction.obs);
    }

    for (var auction in auctions) {
      if (auction.location == null) {
        continue;
      }
      var auctionsInTheSameLocation =
          _auctionsInLocation[auction.location!]?.length;

      _addAuctionMarker(
        auction.location!,
        auction,
        auctionsInTheSameLocation,
      );
    }

    showLoadedAuctionsFlash(loadedAuctions, _loadedAuctions.length);
    if (mounted) {
      setState(() {
        _auctionsLoading = false;
      });
    }
  }

  void _addAuctionMarker(
    LatLng latLng,
    Auction auction,
    int? auctionsInTheSameLocation,
  ) async {
    if (_markers.containsKey(auction.id)) {
      return;
    }

    var marker = MapAuctionsMarker(
      assets: auction.assets ?? [],
      auctionsInTheSameLocation: auctionsInTheSameLocation ?? 0,
    );

    MarkerGenerator(
      [marker],
      (bitmaps) {
        var marker = Marker(
          markerId: MarkerId(auction.id),
          position: latLng,
          icon: BitmapDescriptor.bytes(bitmaps[0]),
          onTap: () {
            _animateCameraToLocation(latLng);
            _openBottomSheet(latLng);
          },
        );

        _markers[auction.id] = marker;
        if (mounted) {
          setState(() {
            _markers = _markers;
          });
        }
      },
    ).generate(context);
  }

  void _handleMapCreate(GoogleMapController controller) async {
    _controller = controller;
    if (mounted) {
      setState(() {});
    }

    try {
      var location = await getGeoLocationPosition();
      _animateCameraToLocation(location);
      _loadAuctions();
    } catch (error) {
      if (!mounted) {
        return;
      }

      var result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return LocationNotAvailableDialog(
            permissionStatus: error.toString(),
          );
        },
      );

      if (result == false && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void handleCameraMove(CameraPosition position) async {
    var location = LatLng(position.target.latitude, position.target.longitude);
    mapAuctionsController.updateCurrentMapPosition(location);

    await _loadAuctions();
  }

  Widget _renderGoogleMap() {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: GoogleMap(
          style: Get.isDarkMode
              ? mapsController.darkMapStyle.value
              : mapsController.lightMapStyle.value,
          initialCameraPosition: _initialCameraPos,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          markers: _mapZoom < 10 ? {} : _markers.values.toSet(),
          onLongPress: (LatLng latLng) {},
          mapToolbarEnabled: false,
          onTap: (position) {},
          myLocationButtonEnabled: true,
          onCameraMove: (CameraPosition position) {
            if (mounted) {
              setState(() {
                _mapZoom = position.zoom;
              });
            }
            EasyDebounce.debounce(
              'camera-move',
              const Duration(milliseconds: 1000),
              () => handleCameraMove(position),
            );
          },
          onMapCreated: (GoogleMapController controller) {
            _handleMapCreate(controller);
          },
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          }),
    );
  }

  Widget _renderZoomInfoCard() {
    return InfoCard(
      dismissible: false,
      background:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      handleClose: () {},
      child: Row(
        children: [
          Flexible(
            child: Text(
              'map_auctions.need_to_zoom_in',
              style: Theme.of(context).extension<CustomThemeFields>()!.smallest,
            ).tr(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_1,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            _renderGoogleMap(),
            _mapZoom < 10
                ? Positioned(
                    left: 0,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 80,
                      width: Get.width,
                      child: _renderZoomInfoCard(),
                    ),
                  )
                : Container(),
            Positioned(
              top: 16,
              left: 0,
              child: SizedBox(
                width: Get.width,
                child: ListView.builder(
                  key: UniqueKey(),
                  shrinkWrap: true,
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: Get.width,
                      height: 108,
                      child: Column(
                        children: [
                          MapAuctionsLocationSearchbar(
                            handleSelectPrediction: (location) =>
                                _animateCameraToLocation(location),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: MapAuctionsCategorySelectDropdown(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              child: _auctionsLoading
                  ? SizedBox(
                      width: Get.width,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .background_1,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .separator,
                            ),
                          ),
                          child: Wrap(children: [
                            Text(
                              'map_auctions.loading_auctions',
                              style: Theme.of(context)
                                  .extension<CustomThemeFields>()!
                                  .smaller,
                            ).tr(),
                            Container(
                              width: 16,
                            ),
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Theme.of(context)
                                    .extension<CustomThemeFields>()!
                                    .fontColor_1,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}
