import 'package:intl/intl.dart';

class TFormatter {
  TFormatter._();

  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date);
  }

  static String formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$month $day, $year at $hour:$minute';
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'ms_MY', symbol: 'RM').format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Ensure the phone number starts with "60" (Malaysia country code)
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '60${phoneNumber.substring(1)}';
    } else if (!phoneNumber.startsWith('60')) {
      phoneNumber = '60$phoneNumber';
    }

    // Return the formatted phone number with +60
    return '+$phoneNumber';
  }

  // Not fully tested
  static String internationalFormatPhoneNumber(String phoneNumber) {
    // Remove all non-numeric characters
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Extract the country code from the digitsOnly
    String countryCode = '+${digitsOnly.substring(0, 2)}';
    digitsOnly = digitsOnly.substring(2);
    
    // Add the remaining digits with proper formatting
    final formattedNumber = StringBuffer();
    formattedNumber.write('($countryCode)');
    
    int i = 0;
    while (i < digitsOnly.length) {
      int groupLength = 2;
      if (i == 0 && countryCode == '+1') {
        groupLength = 3;
      }
      
      int end = i + groupLength;
      formattedNumber.write(digitsOnly.substring(i, end));
      
      if (end < digitsOnly.length) {
        formattedNumber.write(' ');
      }

      i = end;
    }

    return formattedNumber.toString();
  }
}