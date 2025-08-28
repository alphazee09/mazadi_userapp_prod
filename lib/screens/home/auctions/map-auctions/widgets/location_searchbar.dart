import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:math' as math;

import '../../../../../theme/extensions/base.dart';
import '../../../../../widgets/common/fullscreen-location-selector/prediction_tile.dart';

// ignore: must_be_immutable
class MapAuctionsLocationSearchbar extends StatefulWidget {
  Function handleSelectPrediction;

  MapAuctionsLocationSearchbar({
    super.key,
    required this.handleSelectPrediction,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MapAuctionsLocationSearchbarState createState() =>
      _MapAuctionsLocationSearchbarState();
}

class _MapAuctionsLocationSearchbarState
    extends State<MapAuctionsLocationSearchbar> {
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectLocationPrediction(Prediction prediction) async {
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

    widget.handleSelectPrediction(location);
  }

  Future _triggerLocationsSuggestionsBuild(String keyword) async {
    var result = await places.autocomplete(keyword);
    return result.predictions;
  }

  @override
  Widget build(BuildContext context) {
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

    var placeholder = tr('map_auctions.search_locations');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            decoration: inputDecoration.copyWith(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fillColor: Theme.of(context)
                  .extension<CustomThemeFields>()!
                  .background_1,
              hintText: placeholder,
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
                    Navigator.pop(context);
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
          return await _triggerLocationsSuggestionsBuild(pattern);
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
          _selectLocationPrediction(prediction);
        },
        // validator: (value) {
        //   if (value!.isEmpty) {
        //     return tr("location.select_location");
        //   }
        //   return null;
        // },
      ),
    );
  }
}
