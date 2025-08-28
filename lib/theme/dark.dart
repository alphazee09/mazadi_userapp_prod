import 'package:mazadi/theme/colors.dart';
import 'package:mazadi/theme/extensions/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme() {
  final ThemeData base = ThemeData.dark();

  return base.copyWith(
    appBarTheme: base.appBarTheme.copyWith(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: DarkColors.background_1,
        statusBarBrightness: Brightness.light,
      ),
      surfaceTintColor: DarkColors.background_1,
    ),
    bottomAppBarTheme: base.bottomAppBarTheme.copyWith(
      surfaceTintColor: DarkColors.background_1,
    ),
    datePickerTheme: datePickerThemeData,
    unselectedWidgetColor: DarkColors.font_1,
    extensions: <CustomThemeFields>[darkThemeExtensionColors],
  );
}

var datePickerThemeData = DatePickerThemeData(
  backgroundColor: DarkColors.background_2,
  headerBackgroundColor: DarkColors.background_3,
  headerForegroundColor: DarkColors.font_1,
  dayStyle: TextStyle(
    color: DarkColors.font_1,
    fontSize: 16,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return DarkColors.font_3;
    }
    if (states.contains(WidgetState.disabled)) {
      return DarkColors.background_3;
    }
    return Colors.transparent;
  }),
  todayForegroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return DarkColors.background_3;
    }
    return DarkColors.font_1;
  }),
  dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return DarkColors.font_3;
    }
    if (states.contains(WidgetState.disabled)) {
      return DarkColors.background_3;
    }
    return Colors.transparent;
  }),
  cancelButtonStyle: ButtonStyle(
    overlayColor: WidgetStateProperty.all(DarkColors.background_1),
    backgroundColor: WidgetStateProperty.all(DarkColors.background_3),
    foregroundColor: WidgetStateProperty.all(DarkColors.font_1),
  ),
  confirmButtonStyle: ButtonStyle(
    overlayColor: WidgetStateProperty.all(DarkColors.background_1),
    backgroundColor: WidgetStateProperty.all(DarkColors.background_3),
    foregroundColor: WidgetStateProperty.all(DarkColors.font_1),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: DarkColors.font_3,
      fontSize: 16,
      fontFamily: GoogleFonts.nunitoSans().fontFamily,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: DarkColors.font_3,
      ),
    ),
    labelStyle: TextStyle(
      color: DarkColors.font_3,
      fontSize: 16,
      fontFamily: GoogleFonts.nunitoSans().fontFamily,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: DarkColors.font_3,
      ),
    ),
  ),
  dayForegroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return DarkColors.background_3;
    }
    return DarkColors.font_1;
  }),
  headerHeadlineStyle: TextStyle(
    color: DarkColors.font_1,
    fontSize: 20,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  weekdayStyle: TextStyle(
    color: DarkColors.font_3,
    fontSize: 16,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
);

var darkThemeExtensionColors = CustomThemeFields(
  background_1: DarkColors.background_1,
  background_2: DarkColors.background_2,
  background_3: DarkColors.background_3,
  title: TextStyle(
    color: DarkColors.font_1,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  subtitle: TextStyle(
    color: DarkColors.font_2,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w300,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  smaller: TextStyle(
    color: DarkColors.font_1,
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w300,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  smallest: TextStyle(
    color: DarkColors.font_3,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w300,
    fontFamily: GoogleFonts.nunitoSans().fontFamily,
  ),
  separator: DarkColors.separator,
  fontColor_1: DarkColors.font_1,
  fontColor_2: DarkColors.font_2,
  fontColor_3: DarkColors.font_3,
  action: DarkColors.callToAction,
);
