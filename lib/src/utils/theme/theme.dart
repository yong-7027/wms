import 'package:flutter/material.dart';

import 'widget_themes/appbar_theme.dart';
import 'widget_themes/bottom_sheet_theme.dart';
import 'widget_themes/checkbox_theme.dart';
import 'widget_themes/chip_theme.dart';
import 'widget_themes/divider_theme.dart';
import 'widget_themes/elevated_button_theme.dart';
import 'widget_themes/outlined_button_theme.dart';
import 'widget_themes/text_button_theme.dart';
import 'widget_themes/text_formfield_theme.dart';
import 'widget_themes/text_theme.dart';

class TAppTheme {
  // Private constructor
  TAppTheme._();

  static const MaterialColor primarySwatch = MaterialColor(
    0xff017aff,
    <int, Color>{
      50: Color(0xffe3f2fd), // 更浅的颜色
      100: Color(0xffbbdefb),
      200: Color(0xff90caf9),
      300: Color(0xff64b5f6),
      400: Color(0xff42a5f5),
      500: Color(0xff2196f3), // 主颜色
      600: Color(0xff1e88e5),
      700: Color(0xff1976d2),
      800: Color(0xff1565c0),
      900: Color(0xff0d47a1), // 更深的颜色
    },
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    primarySwatch: primarySwatch,
    primaryColor: primarySwatch,
    brightness: Brightness.light,
    textTheme: TTextTheme.lightTextTheme,
    chipTheme: TChipTheme.lightChipTheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    textButtonTheme: TTextButtonTheme.lightTextButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
    dividerTheme: TDividerTheme.lightDividerTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    primarySwatch: primarySwatch,
    primaryColor: primarySwatch,
    brightness: Brightness.dark,
    textTheme: TTextTheme.darkTextTheme,
    chipTheme: TChipTheme.darkChipTheme,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    textButtonTheme: TTextButtonTheme.darkTextButtonTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
    dividerTheme: TDividerTheme.darkDividerTheme,
  );
}