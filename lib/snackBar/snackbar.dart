import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSncackBar({
  required titleText,
  required captionText,
  required textColor,
  required bgColor,
  required icon,
}) {
  Get.snackbar(
    '',
    '',
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.all(16),
    titleText: Text(
      titleText,
      style: TextStyle(
        color: textColor,
        fontFamily: 'vazir',
      ),
      textDirection: TextDirection.rtl,
    ),
    messageText: Text(
      captionText,
      style: TextStyle(
        color: textColor,
        fontFamily: 'vazir',
      ),
      textDirection: TextDirection.rtl,
    ),
    colorText: textColor,
    icon: icon,
    snackPosition: SnackPosition.TOP,
    duration: const Duration(seconds: 3),
    backgroundColor: bgColor,
  );
}
