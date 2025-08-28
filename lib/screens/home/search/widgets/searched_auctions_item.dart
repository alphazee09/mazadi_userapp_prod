import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';

import 'package:get/get.dart';

import '../../../../core/controllers/categories.dart';
import '../../../../core/models/auction.dart';

class SearchedAuctionsSuggestionItem extends StatelessWidget {
  final categoriesController = Get.find<CategoriesController>();

  final Auction auction;
  final Function? onTap;
  final BuildContext ctx;

  SearchedAuctionsSuggestionItem({
    required this.auction,
    required this.ctx,
    this.onTap,
  });

  Widget _renderAuctionAsset() {
    var assets = auction.assets ?? [];
    var assetsLen = assets.length;
    var serverBaseUrl = FlutterConfig.get('SERVER_URL');

    if (assetsLen == 0) {
      return SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset('assets/jpg/default-item.jpeg'),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        '$serverBaseUrl/assets/${assets[0].path}',
        fit: BoxFit.cover,
        width: double.infinity,
        height: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(ctx).extension<CustomThemeFields>()!.background_1,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: _renderAuctionAsset(),
              ),
              Container(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            auction.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(ctx)
                                .extension<CustomThemeFields>()!
                                .smaller,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 8,
                    ),
                    Text(
                      categoriesController
                              .findById(auction.subCategoryId)!
                              .name[Get.locale.toString()] ??
                          '',
                      style: Theme.of(ctx)
                          .extension<CustomThemeFields>()!
                          .smallest,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
