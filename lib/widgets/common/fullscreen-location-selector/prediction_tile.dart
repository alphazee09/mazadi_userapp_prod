import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_webservice/places.dart';

class PredictionTile extends StatelessWidget {
  final Prediction prediction;
  final ValueChanged<Prediction>? onTap;

  const PredictionTile({
    super.key,
    required this.prediction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).extension<CustomThemeFields>()!.background_1,
      leading: SvgPicture.asset(
        'assets/icons/svg/location.svg',
        semanticsLabel: 'Location',
        height: 20,
        colorFilter: ColorFilter.mode(
          Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
          BlendMode.srcIn,
        ),
      ),
      title: RichText(
        text: TextSpan(
          children: _buildPredictionText(context),
        ),
      ),
    );
  }

  List<TextSpan> _buildPredictionText(BuildContext context) {
    final List<TextSpan> result = <TextSpan>[];

    if (prediction.matchedSubstrings.isNotEmpty) {
      MatchedSubstring matchedSubString = prediction.matchedSubstrings[0];
      // There is no matched string at the beginning.
      if (matchedSubString.offset > 0) {
        result.add(TextSpan(
          text: prediction.description
              ?.substring(0, matchedSubString.offset as int?),
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ));
      }

      // Matched strings.
      result.add(
        TextSpan(
          text: prediction.description?.substring(
              matchedSubString.offset as int,
              matchedSubString.offset + matchedSubString.length as int?),
          style: Theme.of(context)
              .extension<CustomThemeFields>()!
              .smaller
              .copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );

      // Other strings.
      if (matchedSubString.offset + matchedSubString.length <
          (prediction.description?.length ?? 0)) {
        result.add(
          TextSpan(
            text: prediction.description?.substring(
                matchedSubString.offset + matchedSubString.length as int),
            style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
          ),
        );
      }
      // If there is no matched strings, but there are predicts. (Not sure if this happens though)
    } else {
      result.add(
        TextSpan(
          text: prediction.description,
          style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
        ),
      );
    }

    return result;
  }
}
