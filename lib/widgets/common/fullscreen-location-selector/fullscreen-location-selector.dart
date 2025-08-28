import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';
import 'package:custom_info_window/custom_info_window.dart';
import '../../../core/controllers/location.dart';
import '../../../core/controllers/maps.dart';
import '../../../theme/colors.dart';
import '../simple_button.dart';
import '../../dialogs/go_back_confirmation.dart';
import 'prediction_tile.dart';

class FullscreenLocationSelectorScreen extends StatefulWidget {
  final bool isBid;
  const FullscreenLocationSelectorScreen({
    super.key,
    this.isBid = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FullscreenLocationSelectorScreen createState() =>
      _FullscreenLocationSelectorScreen();
}

class _FullscreenLocationSelectorScreen
    extends State<FullscreenLocationSelectorScreen> {
  final mapsController = Get.find<MapsController>();

  // late String _darkMapStyle;
  // late String _lightMapStyle;

  late GoogleMapController _controller;

  final _customInfoWindowController = CustomInfoWindowController();
  final locationController = Get.find<LocationController>();
  // var dialogController = Get.find<DialogsController>();

  late LatLng? initialLatLngLocation;
  late String initialLocationPretty;

  late CameraPosition _initialCameraPos = const CameraPosition(
    target: LatLng(32.080664, 34.9563837),
    zoom: 14.0,
  );

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final typeAheadKey = GlobalKey();

  final _searchController = TextEditingController();
  late final GoogleMapsPlaces places;

  @override
  void initState() {
    super.initState();

    var apiKey = FlutterConfig.get('GOOGLE_MAPS_API_KEY');
    if (apiKey == '' || apiKey.isEmpty) {
      print('GOOGLE_MAPS_API_KEY is not set');
    }

    places = GoogleMapsPlaces(apiKey: apiKey);

    initialLatLngLocation = locationController.latLng.value;
    initialLocationPretty = locationController.location.value;

    if (locationController.latLng.value != null) {
      _initialCameraPos = CameraPosition(
        target: locationController.latLng.value!,
        zoom: 14.0,
      );

      addNewMarkerWithCircle(locationController.latLng.value!);
    }
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleGoBack() {
    var newLocation = locationController.latLng.value;
    if (initialLatLngLocation != null &&
        initialLatLngLocation!.latitude == newLocation?.latitude &&
        initialLatLngLocation!.longitude == newLocation?.longitude) {
      Navigator.pop(context);
      return;
    }

    showGoBackConfirmationDialog(() {
      locationController.setMarkerLatLong(initialLatLngLocation);
      locationController.setLocation(initialLocationPretty);
    });
  }

  void showGoBackConfirmationDialog(Function onSubmit) {
    var alert = GoBackConfirmationDialog(onSubmit: onSubmit);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error(tr('location.location_disabled'));
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(tr('location.location_denied'));
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(tr('location.location_permanent_denied'));
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void addNewMarkerWithCircle(LatLng latLng) {
    var uuid = const Uuid();
    var newMarkerId = MarkerId(uuid.v4());

    _markers.add(Marker(
      markerId: newMarkerId,
      position: latLng,
      icon: BitmapDescriptor.defaultMarker,
    ));

    _circles.add(
      Circle(
        circleId: CircleId(uuid.v4()),
        center: latLng,
        radius: 300,
        strokeWidth: 0,
        fillColor: Colors.blue.withOpacity(0.5),
      ),
    );
  }

  Future<void> _handleAddMarker(LatLng latLng) async {
    if (mounted) {
      setState(() {
        _markers.clear();
        _circles.clear();

        addNewMarkerWithCircle(latLng);
      });
    }

    var latitude = latLng.latitude;
    var longitude = latLng.longitude;
    var placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) {
      return;
    }

    var locality = placemarks[0].locality;
    var subadministrativeArea = placemarks[0].subAdministrativeArea;
    var administrativeArea = placemarks[0].administrativeArea;
    var location = locality != null && locality.isNotEmpty
        ? locality
        : subadministrativeArea != null && subadministrativeArea.isNotEmpty
            ? subadministrativeArea
            : administrativeArea as String;

    locationController.setLocation(location);
    locationController.setMarkerLatLong(latLng);

    _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 16)));
  }

  void _handleMapCreate(GoogleMapController controller) async {
    _controller = controller;
    _customInfoWindowController.googleMapController = controller;
    if (locationController.latLng.value != null) {
      return;
    }

    try {
      var pos = await _getGeoLocationPosition();
      var latLong = LatLng(pos.latitude, pos.longitude);

      _handleAddMarker(latLong);
    } catch (e) {
      print('error: $e');
    }
  }

  Widget _renderGoogleMap(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: Get.height,
          width: Get.width,
          child: GoogleMap(
              initialCameraPosition: _initialCameraPos,
              myLocationEnabled: false,
              markers: _markers,
              circles: _circles,
              style: Get.isDarkMode
                  ? mapsController.darkMapStyle.value
                  : mapsController.lightMapStyle.value,
              onLongPress: (LatLng latLng) {
                _handleAddMarker(latLng);
              },
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
              },
              onCameraMove: (position) {
                _customInfoWindowController.onCameraMove!();
              },
              onMapCreated: (GoogleMapController controller) async {
                _handleMapCreate(controller);
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              }),
        ),
        Positioned(
          bottom: 16,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_1
                  .withOpacity(0.9),
            ),
            width: Get.width * 0.7,
            child: Text(
              'location.long_tap',
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ).tr(),
          ),
        ),
      ],
    );
  }

  Future triggerLocationsSuggestionsBuild(String keyword) async {
    var result = await places.autocomplete(keyword);
    return result.predictions;
  }

  void selectLocationPrediction(Prediction prediction) async {
    if (prediction.placeId == null || prediction.placeId!.isEmpty) {
      return;
    }
    var details =
        await places.getDetailsByPlaceId(prediction.placeId as String);

    if (details.result.geometry == null) {
      return;
    }

    var location = LatLng(
      details.result.geometry!.location.lat,
      details.result.geometry!.location.lng,
    );

    await _handleAddMarker(location);
  }

  Widget _renderLocationSearchBar() {
    var inputDecoration = InputDecoration(
      fillColor: Theme.of(context).extension<CustomThemeFields>()!.background_2,
      hintStyle: Theme.of(context).extension<CustomThemeFields>()!.smaller,
      filled: true,
      contentPadding: const EdgeInsetsDirectional.only(start: 14, end: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).extension<CustomThemeFields>()!.separator,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
          width: 1,
        ),
      ),
    );

    var searchByCity = tr("location.search_by_city");
    return Row(
      children: [
        Expanded(
          child: TypeAheadField(
            key: typeAheadKey,
            hideOnEmpty: true,
            offset: Offset(8, 8),
            // suggestionsBoxDecoration: SuggestionsBoxDecoration(
            //   color: Theme.of(context)
            //       .extension<CustomThemeFields>()!
            //       .background_2,
            //   elevation: 2,
            //   borderRadius: BorderRadius.circular(8),
            // ),
            builder: (context, controller, focusNode) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: false,
                scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                style:
                    Theme.of(context).extension<CustomThemeFields>()!.smaller,
                decoration: inputDecoration.copyWith(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fillColor: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .background_1,
                  hintText: searchByCity,
                  prefixIcon: Transform.rotate(
                    angle: 180 * math.pi / 180,
                    child: IconButton(
                      splashRadius: 24,
                      icon: SvgPicture.asset(
                        'assets/icons/svg/next.svg',
                        // ignore: deprecated_member_use
                        color: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .fontColor_1,
                        semanticsLabel: 'Next',
                      ),
                      onPressed: () {
                        _handleGoBack();
                      },
                    ),
                  ),
                ),
              );
            },
            suggestionsCallback: (pattern) async {
              if (pattern.isEmpty) {
                return [];
              }
              return await triggerLocationsSuggestionsBuild(pattern);
            },
            itemBuilder: (context, prediction) {
              return PredictionTile(prediction: prediction as Prediction);
            },
            loadingBuilder: ((context) {
              return Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .fontColor_1,
                  ),
                ),
              );
            }),
            // onSaved: (value) {
            //   _searchController.text = value as String;
            // },
            onSelected: (prediction) {
              _searchController.text =
                  (prediction as Prediction).description as String;
              selectLocationPrediction(prediction);
            },
            // validator: (value) {
            //   if (value!.isEmpty) {
            //     return tr("location.select_location");
            //   }
            //   return null;
            // },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var selectLocationText = tr("location.select_location");

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor:
              Theme.of(context).extension<CustomThemeFields>()!.background_1,
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              _renderGoogleMap(context),
              Positioned(
                top: 16,
                left: 16,
                child: SizedBox(
                  width: Get.width - 32,
                  child: _renderLocationSearchBar(),
                ),
              ),
              CustomInfoWindow(
                controller: _customInfoWindowController,
                height: 110,
                width: 200,
                offset: 50,
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              height: 128,
              color: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_1,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Obx(
                          () => locationController.location.isNotEmpty
                              ? Center(
                                  child: Text(
                                    locationController.location.value,
                                    style: Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .title
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                  ),
                                )
                              : Flexible(
                                  child: Text(
                                    'location.to_create_pin',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .extension<CustomThemeFields>()!
                                        .subtitle,
                                  ).tr(),
                                ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 8,
                  ),
                  SimpleButton(
                    onPressed: () async {
                      if (locationController.location.isNotEmpty) {
                        Navigator.pop(context);
                      }
                    },
                    background: _markers.isEmpty
                        ? Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .separator
                        : Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .action,
                    width: Get.width,
                    child: Text(
                      selectLocationText,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .title
                          .copyWith(
                            color: DarkColors.font_1,
                          ),
                    ).tr(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
