import 'dart:async';

import 'package:mazadi/core/models/account.dart';
import 'package:mazadi/screens/home/categories/category_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';
import 'package:get/get.dart';

import '../../../core/controllers/account.dart';
import '../../../core/controllers/categories.dart';
import '../../../core/models/category.dart';
import '../../../core/navigator.dart';
import '../../../theme/extensions/base.dart';
import '../../../widgets/common/section_heading.dart';
import '../preferred-categories/index.dart';
import 'list/index.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeCategoriesState createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  final categoriesController = Get.find<CategoriesController>();
  final accountController = Get.find<AccountController>();
  final navigatorService = Get.find<NavigatorService>();

  List<Rx<Category>> categories = [];
  StreamSubscription<List<Rx<Category>>>? _categoriesSubscription;
  StreamSubscription<Account>? _preferredCategoriesSubscription;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        if (!mounted) {
          return;
        }

        categories.clear();
        categories
            .addAll(categoriesController.getPersonalizedCategoriesForHome());
      });
    }

    _categoriesSubscription = categoriesController.categories.listen((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        categories.clear();
        categories.addAll(
          categoriesController.getPersonalizedCategoriesForHome(),
        );
      });
    });

    _preferredCategoriesSubscription = accountController.account.listen((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        categories.clear();
        categories.addAll(
          categoriesController.getPersonalizedCategoriesForHome(),
        );
      });
    });
  }

  @override
  void dispose() {
    _categoriesSubscription?.cancel();
    _preferredCategoriesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: SectionHeading(
            onPressed: () {
              navigatorService.push(
                CategoriesScreen(
                  categories: categoriesController.categories,
                ),
                NavigationStyle.SharedAxis,
              );
            },
            title: tr('home.categories.categories'),
            withMore: true,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutGrid(
            columnSizes: [1.fr, 1.fr, 1.fr],
            rowSizes: [152.px, 152.px],
            rowGap: 8,
            columnGap: 8,
            children: [
              for (var cat in categories)
                CategoryButton(
                  category: cat.value,
                  height: double.infinity,
                ),
            ],
          ),
        ),
        Container(
          height: 16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTap(
              onPressed: () {
                navigatorService.push(
                  AccountPreferredCategoriesScreen(),
                );
              },
              child: SizedBox(
                height: 24,
                child: Text(
                  'home.preferred_categories.update',
                  style: Theme.of(context)
                      .extension<CustomThemeFields>()!
                      .smaller
                      .copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                ).tr(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
