import 'package:easy_localization/easy_localization.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final Widget? titlePrefix;
  final String? titleSufix;
  final Widget? titleWidgetSufix;

  final Widget? sufix;

  final bool withMore;
  final String? moreText;
  final VoidCallback? onPressed;
  final VoidCallback? onMorePressed;
  final double padding;
  final BuildContext? ctx;

  SectionHeading({
    super.key,
    required this.title,
    this.onPressed,
    this.titleSufix,
    this.titleWidgetSufix,
    this.sufix,
    this.titlePrefix,
    String? moreText,
    this.onMorePressed,
    this.withMore = true,
    this.padding = 16,
    this.ctx,
  }) : moreText = moreText ?? tr('generic.see_all');

  @override
  Widget build(BuildContext context) {
    var contextToUse = ctx ?? context;
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
          onTap: () {
            if (onPressed != null) {
              onPressed!();
            }
          },
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        titlePrefix ?? Container(),
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(contextToUse)
                                .extension<CustomThemeFields>()!
                                .title,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        titleWidgetSufix ?? Container(),
                        Container(
                          width: 16,
                        ),
                        titleSufix != null
                            ? Text(
                                titleSufix ?? '',
                                style: Theme.of(contextToUse)
                                    .extension<CustomThemeFields>()!
                                    .subtitle,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      sufix ?? Container(),
                      withMore
                          ? TextButton(
                              onPressed: () {
                                if (onMorePressed != null) {
                                  onMorePressed!();
                                  return;
                                }
                                onPressed!();
                              },
                              child: Text(moreText!,
                                  style: Theme.of(contextToUse)
                                      .extension<CustomThemeFields>()!
                                      .smaller),
                            )
                          : Container()
                    ],
                  )
                ],
              ))),
    );
  }
}
