import 'package:flutter/material.dart';

@immutable
class CustomThemeFields extends ThemeExtension<CustomThemeFields> {
  const CustomThemeFields({
    required this.background_1,
    required this.background_2,
    required this.background_3,
    required this.action,
    required this.title,
    required this.subtitle,
    required this.fontColor_1,
    required this.fontColor_2,
    required this.fontColor_3,
    required this.smaller,
    required this.smallest,
    required this.separator,
  });

  final Color background_1;
  final Color background_2;
  final Color background_3;
  final Color action;
  final TextStyle title;
  final TextStyle subtitle;
  final Color fontColor_1;
  final Color fontColor_2;
  final Color fontColor_3;
  final TextStyle smaller;
  final TextStyle smallest;
  final Color separator;

  @override
  CustomThemeFields copyWith({
    Color? background_1,
    Color? background_2,
    Color? background_3,
    Color? action,
    TextStyle? title,
    TextStyle? subtitle,
    Color? fontColor_1,
    Color? fontColor_2,
    Color? fontColor_3,
    TextStyle? smaller,
    TextStyle? smallest,
    Color? separator,
  }) {
    return CustomThemeFields(
      background_1: background_1 ?? this.background_1,
      background_2: background_2 ?? this.background_2,
      background_3: background_3 ?? this.background_3,
      action: action ?? this.action,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      fontColor_1: fontColor_1 ?? this.fontColor_1,
      fontColor_2: fontColor_2 ?? this.fontColor_2,
      fontColor_3: fontColor_3 ?? this.fontColor_3,
      smaller: smaller ?? this.smaller,
      smallest: smallest ?? this.smallest,
      separator: separator ?? this.separator,
    );
  }

  @override
  CustomThemeFields lerp(CustomThemeFields? other, double t) {
    if (other is! CustomThemeFields) {
      return this;
    }
    return CustomThemeFields(
      background_1: Color.lerp(background_1, other.background_1, t)!,
      background_2: Color.lerp(background_2, other.background_2, t)!,
      background_3: Color.lerp(background_3, other.background_3, t)!,
      action: Color.lerp(action, other.action, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      subtitle: TextStyle.lerp(subtitle, other.subtitle, t)!,
      fontColor_1: Color.lerp(fontColor_1, other.fontColor_1, t)!,
      fontColor_2: Color.lerp(fontColor_2, other.fontColor_2, t)!,
      fontColor_3: Color.lerp(fontColor_3, other.fontColor_3, t)!,
      smaller: TextStyle.lerp(smaller, other.smaller, t)!,
      smallest: TextStyle.lerp(smallest, other.smallest, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
    );
  }

  // Optional
  @override
  String toString() => 'MyColors(brandColor: $background_1)';
}
