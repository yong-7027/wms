import 'package:flutter/material.dart';

class TColors {
  TColors._();

  /* -- App Basic Colors -- */
  static const Color primary = Color(0xff017aff);
  static const Color secondary = Color(0xff143371);
  static const Color third = Color(0xff5f94c2);
  static const Color accent = Color(0xffb0c7ff);
  static const Color lightBlueColor = Color(0xffe9f2ff);

  /* -- Text Colors -- */
  static const Color textPrimary = Color(0xff333333);
  static const Color textSecondary = Color(0xff6c757d);
  static const Color textWhite = Color(0xffffffff);

  /* -- Background Colors -- */
  static const Color light = Color(0xfff6f6f6);
  static const Color dark = Color(0xff272727);
  static const Color primaryBackground = Color(0xfff3f5ff);

  /* -- Background Container Colors -- */
  static const Color lightContainer = Color(0xfff6f6f6);
  static Color darkContainer = Colors.white.withOpacity(0.1);

  /* -- Button Colors -- */
  static const Color buttonPrimary = Color(0xff017aff);
  static const Color buttonSecondary = Color(0xff6c7570);
  static const Color buttonDisabled = Color(0xffc4c4c4);

  /* -- Border Colors -- */
  static const Color borderPrimary = Color(0xffd9d9d9);
  static const Color borderSecondary = Color(0xffe6e6e6);

  /* -- Error and Validation Colors -- */
  static const Color error = Color(0xffd32f2f);
  static const Color success = Color(0xff388e3c);
  static const Color warning = Color(0xfff57c00);
  static const Color info = Color(0xff1976d2);

  /* -- Neutral Shades -- */
  static const Color black = Color(0xff232323);
  static const Color darkerGrey = Color(0xff4f4f4f);
  static const Color darkGrey = Color(0xff939393);
  static const Color grey = Color(0xffe0e0e0);
  static const Color softGrey = Color(0xfff4f4f4);
  static const Color lightGrey = Color(0xfff9f9f9);
  static const Color white = Color(0xffffffff);

  /* -- Additional Colors for Invoice System -- */
  static const Color invoicePaid = Color(0xff4caf50);
  static const Color invoiceUnpaid = Color(0xffff9800);
  static const Color invoiceOverdue = Color(0xfff44336);
  static const Color invoiceVoid = Color(0xff9e9e9e);

  /* -- Service Type Colors -- */
  static const Color serviceColor = Color(0xff2196f3);
  static const Color partColor = Color(0xffff9800);

  /* -- Payment Method Colors -- */
  static const Color stripeColor = Color(0xff635bff);
  static const Color paypalColor = Color(0xff00457c);
  static const Color razorpayColor = Color(0xff528ff0);

  static const Color tCardBgColor = Color(0xfff7f6f1);
}