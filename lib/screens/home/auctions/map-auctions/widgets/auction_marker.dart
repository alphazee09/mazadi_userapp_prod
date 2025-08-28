import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import '../../../../../core/models/asset.dart';
import '../../../../../theme/extensions/base.dart';

class MapAuctionsMarker extends StatefulWidget {
  final List<Asset> assets;
  final int auctionsInTheSameLocation;

  const MapAuctionsMarker({
    super.key,
    required this.assets,
    required this.auctionsInTheSameLocation,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MapAuctionsMarkerState createState() => _MapAuctionsMarkerState();
}

// ignore: must_be_immutable
class _MapAuctionsMarkerState extends State<MapAuctionsMarker> {
  @override
  Widget build(BuildContext context) {
    var serverBaseUrl = FlutterConfig.get('SERVER_URL');
    var assetUrl = '$serverBaseUrl/assets/${widget.assets.first.path}';

    return Container(
      height: 110,
      width: 100,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: NetworkImage(assetUrl),
              ),
            ),
          ),
          widget.auctionsInTheSameLocation > 1
              ? Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                    color: Theme.of(context)
                        .extension<CustomThemeFields>()!
                        .separator
                        .withOpacity(0.8),
                  ),
                  child: Center(
                    child: Text(
                      'map_auctions.auctions_count_simple',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller,
                    ).tr(namedArgs: {
                      'no': widget.auctionsInTheSameLocation.toString()
                    }),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
