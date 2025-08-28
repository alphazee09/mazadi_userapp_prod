import 'package:mazadi/core/controllers/account.dart';
import 'package:mazadi/core/models/category.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masonry_grid/masonry_grid.dart';

import '../../../core/controllers/auction.dart';
import '../../../core/controllers/categories.dart';
import '../../../theme/colors.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/action_button.dart';
import '../../../widgets/simple_app_bar.dart';
import 'category_button.dart';

class AccountPreferredCategoriesScreen extends StatefulWidget {
  const AccountPreferredCategoriesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AccountPreferredCategoriesScreenState createState() =>
      _AccountPreferredCategoriesScreenState();
}

class _AccountPreferredCategoriesScreenState
    extends State<AccountPreferredCategoriesScreen> {
  final categoriesController = Get.find<CategoriesController>();
  final accountController = Get.find<AccountController>();
  final auctionsController = Get.find<AuctionController>();

  bool _isSaving = false;

  void handleCategorySelect(Category genre) {
    accountController.togglePreferredCategory(genre.id);
  }

  Future<void> _handleFinish() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    var updated = await accountController.finishCategoriesSetup();
    if (updated) {
      await auctionsController.refreshRecommendations();
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });
    Get.back();
  }

  Widget _renderBottomNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).extension<CustomThemeFields>()!.separator,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: IntrinsicWidth(
              child: SizedBox(
                height: 76,
                child: Row(
                  children: [
                    Container(),
                    Expanded(
                      child: ActionButton(
                        background: Theme.of(context)
                            .extension<CustomThemeFields>()!
                            .action,
                        height: 42,
                        width: 300,
                        isLoading: _isSaving,
                        onPressed: _handleFinish,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'generic.finish',
                            style: Theme.of(context)
                                .extension<CustomThemeFields>()!
                                .title
                                .copyWith(
                                  fontSize: 19,
                                  color: DarkColors.font_1,
                                ),
                          ).tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderPreferredCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 24,
            ),
            Text(
              'home.preferred_categories.info',
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
              textAlign: TextAlign.center,
            ).tr(),
            Container(
              height: 24,
            ),
            Obx(
              () => MasonryGrid(
                column: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  for (var category in categoriesController.categories)
                    PreferredCategoryButton(
                      category: category.value,
                      selected: accountController
                          .categoryIsPreferred(category.value.id),
                      onTap: () => handleCategorySelect(category.value),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<CustomThemeFields>()!.background_1,
        bottomNavigationBar: _renderBottomNavbar(),
        appBar: SimpleAppBar(
          withBack: false,
          withSearch: false,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
              ),
              Text(
                'home.preferred_categories.title',
                style: Theme.of(context).extension<CustomThemeFields>()!.title,
              ).tr(),
            ],
          ),
        ),
        body: Container(
          color: Theme.of(context).extension<CustomThemeFields>()!.background_1,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Center(child: _renderPreferredCategories()),
              ),
              Container(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
