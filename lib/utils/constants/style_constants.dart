import 'package:agent_lab/utils/constants/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class StyleConstants {
  StyleConstants._();

  // Radius & BorderRadius
  static const buttonRadius = Radius.circular(8);
  static final borderRadius = BorderRadius.circular(8);

  // Common TextStyle builder
  static TextStyle textStyle(double size, FontWeight weight, {Color? color}) => TextStyle(
        fontSize: size.sp,
        fontWeight: weight,
        fontFamily: 'sohne',
        color: color,
      );

  // InputDecorations
  static InputDecoration buildInputDecoration({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? fillColor,
    TextStyle? hintStyle,
    EdgeInsets? contentPadding,
  }) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Pallete.primary, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      focusColor: Pallete.primary,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      fillColor: fillColor,
      contentPadding: contentPadding,
      hintText: hintText,
      hintStyle: hintStyle,
    );
  }

  static final emailFormFieldStyle = buildInputDecoration(
    hintText: 'admin@gmail.com',
    prefixIcon: const Icon(Icons.mail_outline_sharp),
  );

  static final emailFormFieldStyle1 = buildInputDecoration(
    hintText: 'AppText.email',
    fillColor: Pallete.greySoft,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    hintStyle: textStyle(12, FontWeight.w400, color: Pallete.greyBarelyMedium),
  );

  static final passwordFormFieldStyle = buildInputDecoration(
    hintText: 'Enter Your Password',
    prefixIcon: const Icon(Icons.lock_outline_sharp),
    suffixIcon: const Icon(Icons.visibility),
  );

  static final style10300 = textStyle(10, FontWeight.w300);
  static final style10400 = textStyle(10, FontWeight.w400);

  static final style11300 = textStyle(11, FontWeight.w300);
  static final style11400 = textStyle(11, FontWeight.w400);

  static final style12300 = textStyle(12, FontWeight.w300);
  static final style12400 = textStyle(12, FontWeight.w400);
  static final style12500 = textStyle(12, FontWeight.w500);
  static final style12600 = textStyle(12, FontWeight.w600);
  static final style12700 = textStyle(12, FontWeight.w700);

  static final style13600 = textStyle(13, FontWeight.w600);

  static final style14300 = textStyle(14, FontWeight.w300);
  static final style14400 = textStyle(14, FontWeight.w400);
  static final style14500 = textStyle(14, FontWeight.w500);
  static final style14600 = textStyle(14, FontWeight.w600);
  static final style14700 = textStyle(14, FontWeight.w700);

  static final style15400 = textStyle(15, FontWeight.w400);
  static final style15500 = textStyle(15, FontWeight.w500);
  static final style15600 = textStyle(15, FontWeight.w600);

  static final style16300 = textStyle(16, FontWeight.w300);
  static final style16400 = textStyle(16, FontWeight.w400);
  static final style16500 = textStyle(16, FontWeight.w500);
  static final style16600 = textStyle(16, FontWeight.w600);
  static final style16700 = textStyle(16, FontWeight.w700);

  static final style17700 = textStyle(17, FontWeight.w700);

  static final style18500 = textStyle(18, FontWeight.w500);
  static final style18600 = textStyle(18, FontWeight.w600);
  static final style18700 = textStyle(18, FontWeight.w700);

  static final style20500 = textStyle(20, FontWeight.w500);
  static final style20600 = textStyle(20, FontWeight.w600);

  static final style21500 = textStyle(21, FontWeight.w500);
  static final style22500 = textStyle(22, FontWeight.w500);
  static final style22700 = textStyle(22, FontWeight.w700);

  static final style24600 = textStyle(24, FontWeight.w600);
  static final style24700 = textStyle(24, FontWeight.w700);

  static final style25400 = textStyle(25, FontWeight.w400);
  static final style25600 = textStyle(25, FontWeight.w600);

  static final style26500 = textStyle(26, FontWeight.w500);
  static final style26700 = textStyle(26, FontWeight.w700);

  static final style28500 = textStyle(28, FontWeight.w500);

  static final style32700 = textStyle(32, FontWeight.w700);
  static final style36700 = textStyle(36, FontWeight.w700);
  static final style40400 = textStyle(40, FontWeight.w400);
  static final style40700 = textStyle(40, FontWeight.w700);

  static final greyTextStyle = textStyle(14, FontWeight.w400, color: Pallete.grey8);
  static final grey22700TextStyle = textStyle(22, FontWeight.w700, color: Pallete.grey8);
  static final grey16500 = textStyle(16, FontWeight.w500, color: Pallete.grey1);
  static final grey18600TextStyle = textStyle(18, FontWeight.w600, color: Pallete.grey8);
  static final greyPanelStyle = textStyle(18, FontWeight.w600, color: Pallete.grey1);

  static final tableHeaderStyle = textStyle(14, FontWeight.w700, color: Pallete.grey1);
  static final subtitleStyle = textStyle(16, FontWeight.w400, color: Pallete.grey1);
}
