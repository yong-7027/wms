import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.black,
      side: const BorderSide(color: TColors.primary), // 边框颜色
      textStyle: const TextStyle(fontSize: 16, color: TColors.black, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: TColors.white,
      side: const BorderSide(color: TColors.lightBlueColor), // 边框颜色
      textStyle: const TextStyle(fontSize: 16, color: TColors.white, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}