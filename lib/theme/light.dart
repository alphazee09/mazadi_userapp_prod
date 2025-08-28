import 'package:mazadi/theme/colors.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: DarkColors.background_1,
        statusBarBrightness: Brightness.light,
      ),
      surfaceTintColor: DarkColors.background_1,
    ),
    bottomAppBarTheme: base.bottomAppBarTheme.copyWith(
      color: DarkColors.background_1,
    ),
    datePickerTheme: datePickerThemeData,
    unselectedWidgetColor: LightColors.font_1,
    extensions: <CustomThemeFields>[lightThemeExtensionColors],
  );
}

var datePickerThemeData = DatePickerThemeData(
  backgroundColor: LightColors.background_2,
  headerBackgroundColor: LightColors.background_3,
  headerForegroundColor: LightColors.font_1,
  dayStyle: TextStyle(
    color: LightColors.font_1,
    fontSize: 16,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return LightColors.font_1;
    }
    if (states.contains(WidgetState.disabled)) {
      return LightColors.background_3;
    }
    return Colors.transparent;
  }),
  todayForegroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return LightColors.background_1;
    }
    return LightColors.font_1;
  }),
  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return LightColors.font_1;
    }
    if (states.contains(WidgetState.disabled)) {
      return LightColors.background_3;
    }
    return Colors.transparent;
  }),
  cancelButtonStyle: ButtonStyle(
    overlayColor: WidgetStateProperty.all(LightColors.background_1),
    backgroundColor: WidgetStateProperty.all(LightColors.background_3),
    foregroundColor: WidgetStateProperty.all(LightColors.font_1),
  ),
  confirmButtonStyle: ButtonStyle(
    overlayColor: WidgetStateProperty.all(LightColors.background_1),
    backgroundColor: WidgetStateProperty.all(LightColors.background_3),
    foregroundColor: WidgetStateProperty.all(LightColors.font_1),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: LightColors.font_3,
      fontSize: 16,
      fontFamily: GoogleFonts.nunitoSans().fontFamily,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: LightColors.font_3,
      ),
    ),
    labelStyle: TextStyle(
      color: LightColors.font_3,
      fontSize: 16,
      fontFamily: GoogleFonts.nunitoSans().fontFamily,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: LightColors.font_3,
      ),
    ),
  ),
  dayForegroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return LightColors.background_3;
    }
    return LightColors.font_1;
  }),
  headerHeadlineStyle: TextStyle(
    color: LightColors.font_1,
    fontSize: 20,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  weekdayStyle: TextStyle(
    color: LightColors.font_3,
    fontSize: 16,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
);

var lightThemeExtensionColors = CustomThemeFields(
  background_1: LightColors.background_1,
  background_2: LightColors.background_2,
  background_3: LightColors.background_3,
  title: TextStyle(
    color: LightColors.font_1,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  subtitle: TextStyle(
    color: LightColors.font_2,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w300,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  smaller: TextStyle(
    color: LightColors.font_1,
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w300,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  smallest: TextStyle(
    color: LightColors.font_3,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w300,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  separator: LightColors.separator,
  fontColor_1: LightColors.font_1,
  fontColor_2: LightColors.font_2,
  fontColor_3: LightColors.font_3,
  action: LightColors.callToAction,
);
