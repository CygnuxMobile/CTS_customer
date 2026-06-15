import 'package:cts_customer/configs/app_colors.dart';
import 'package:flutter/material.dart';


class AppTextStyle {
  static TextStyle regular = TextStyle(color: AppColors.blackColor, fontSize: 16, fontWeight: FontWeight.w400);
  static final TextStyle bold = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);

  static final TextStyle light = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black);

  static TextStyle common({double fontSize = 16, FontWeight fontWeight = FontWeight.w400, Color fontColor = Colors.black, FontStyle? fontStyle}) {
    return TextStyle(fontSize: fontSize, fontWeight: fontWeight, fontStyle: fontStyle, color: fontColor);
  }
}
