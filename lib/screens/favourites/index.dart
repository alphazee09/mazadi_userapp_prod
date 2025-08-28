import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masonry_grid/masonry_grid.dart';
import '../../core/controllers/favourites.dart';
import '../../core/models/auction.dart';
import '../../widgets/auction-card/index.dart';
import 'app_bar.dart';
import 'widgets/no_favourites.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavouritesScreen createState() => _FavouritesScreen();
}

class _FavouritesScreen extends State<FavouritesScreen> {
  final favouritesController = Get.find<FavouritesController>();

  var _activeAuctions = <Rx<Auction>>[];
  var _closedAuctions = <Rx<Auction>>[];

  StreamSubscription<List<Rx<Auction>>>? _favouritesSubscription;

  @override
  void initState() {
    super.initState();
    _activeAuctions = favouritesController.getAuctions();
    _closedAuctions = favouritesController.getAuctions(false);

    favouritesController.favourites.listen((_) {
      if (mounted) {
        setState(() {
          _activeAuctions = favouritesController.getAuctions();
          _closedAuctions = favouritesController.getAuctions(false);
        });
      }
    });
  }

  @override
  void dispose() {
    _favouritesSubscription?.cancel();
    super.dispose();
  }

  Widget _renderAuctions(
    List<Rx<Auction>> auctions,
  ) {
    if (auctions.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: MasonryGrid(
        column: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          for (var auction in auctions)
            AuctionCard(
              auction: auction,
            )
        ],
      ),
    );
  }

  Widget _renderActiveAuctions() {
    if (_activeAuctions.isEmpty) {
      return NoFavouriteAuctionsMessage(forClosedAuctions: false);
    }

    return _renderAuctions(
      _activeAuctions,
    );
  }

  Widget _renderClosedAuctions() {
    if (_closedAuctions.isEmpty) {
      return NoFavouriteAuctionsMessage(forClosedAuctions: true);
    }

    return _renderAuctions(
      _closedAuctions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FavouritesAppBar(
      activeAuctions: _renderActiveAuctions(),
      closedAuctions: _renderClosedAuctions(),
      activeAuctionsLen: _activeAuctions.length,
      closedAuctionsLen: _closedAuctions.length,
    );
  }
}
