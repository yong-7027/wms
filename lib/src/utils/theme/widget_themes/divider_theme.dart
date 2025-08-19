import 'package:flutter/material.dart';

class TDividerTheme {
  TDividerTheme._();

  static DividerThemeData lightDividerTheme = const DividerThemeData(
    color: Color(0xFFD6D6D6),
    thickness: 1.0,
  );

  static DividerThemeData darkDividerTheme = const DividerThemeData(
    color: Color(0xFFE0E0E0),
    thickness: 1.0,
  );
}