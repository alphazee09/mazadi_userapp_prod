import 'package:mazadi/core/models/category.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scale_tap/flutter_scale_tap.dart';

import '../../../theme/extensions/base.dart';
import '../../../widgets/common/category_icon.dart';

class PreferredCategoryButton extends StatelessWidget {
  final Category category;
  final Function onTap;
  final bool selected;

  final double? width;

  PreferredCategoryButton({
    super.key,
    required this.category,
    required this.onTap,
    this.selected = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    var currentLanguage = context.locale.toString();

    return ScaleTap(
      onPressed: () {
        onTap();
      },
      child: Container(
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(
              color: selected
                  ? Theme.of(context).extension<CustomThemeFields>()!.action
                  : Theme.of(context).extension<CustomThemeFields>()!.separator,
              width: 1,
            ),
            color: selected
                ? Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .action
                    .withOpacity(0.1)
                : Theme.of(context)
                    .extension<CustomThemeFields>()!
                    .background_2
                    .withOpacity(0.6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 8,
              ),
              SizedBox(
                height: 42,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    elevation: 0,
                    child: Text(
                      category.name[currentLanguage] ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .extension<CustomThemeFields>()!
                          .smaller
                          .copyWith(
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 8,
              ),
              Material(
                color: Colors.transparent,
                elevation: 0,
                child: CategoryIcon(
                  categoryId: category.id,
                  size: 48,
                  currentLanguage: currentLanguage,
                ),
              ),
              Container(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
