import 'package:mazadi/core/models/category.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../common/category_icon.dart';

class FilterCategoryChip extends StatelessWidget {
  final Category category;
  final Function onRemove;

  const FilterCategoryChip({
    super.key,
    required this.category,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();

    return Chip(
      elevation: 0,
      side: BorderSide.none,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor:
          Theme.of(context).extension<CustomThemeFields>()!.background_2,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryIcon(
            categoryId: category.id,
            size: 24,
            currentLanguage: currentLanguage,
          ),
          Container(
            width: 8,
          ),
          Flexible(
            child: Text(
              category.name[currentLanguage] ?? '',
              style: Theme.of(context).extension<CustomThemeFields>()!.smaller,
            ),
          )
        ],
      ),
      onDeleted: () {},
      deleteIcon: GestureDetector(
        onTap: () {
          onRemove();
        },
        child: SizedBox(
          height: double.infinity,
          width: 16,
          child: SvgPicture.asset(
            'assets/icons/svg/close.svg',
            semanticsLabel: 'Close',
            height: 12,
            colorFilter: ColorFilter.mode(
              Theme.of(context).extension<CustomThemeFields>()!.fontColor_1,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
