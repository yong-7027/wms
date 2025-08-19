import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class THelperFunctions extends GetxController {
  THelperFunctions._();

  /* -- COLORS -- */
  static Color? getColor(String value) {
    value = value.toLowerCase();

    if (value == 'green') {
      return Colors.green;
    } else if (value == 'red') {
      return Colors.red;
    } else if (value == 'blue') {
      return Colors.blue;
    } else if (value == 'pink') {
      return Colors.pink;
    } else if (value == 'grey') {
      return Colors.grey;
    } else if (value == 'purple') {
      return Colors.purple;
    } else if (value == 'black') {
      return Colors.black;
    } else if (value == 'white') {
      return Colors.white;
    } else if (value == 'yellow') {
      return Colors.yellow;
    } else if (value == 'orange') {
      return Colors.orange;
    } else if (value == 'brown') {
      return Colors.brown;
    } else if (value == 'teal') {
      return Colors.teal;
    } else if (value == 'indigo') {
      return Colors.indigo;
    } else {
      return null;
    }
  }

  /* -- ALERT -- */
  static void showAlert(String title, String message) {
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          );
        });
  }

  // 这个方法用于截断一段文字，使其长度不超过指定的最大长度 maxLength。
  // 如果文字长度超出 maxLength，则会取前 maxLength 个字符，并在后面添加省略号 (...)
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  // 将给定的日期格式化为指定格式的字符串
  static String getFormattedDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  // 从列表中移除重复的元素，返回去重后的新列表
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  // 将一组 Widget 按指定的行大小分组，生成多个 Row 组件
  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];
    for (var i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
      wrappedList.add(Row(children: rowChildren,));
    }
    return wrappedList;
  }
}
