import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/constants/app_enums.dart';
import '../../utils/constants/pallete.dart';

class CustomButton extends ConsumerWidget {
  final String title;
  final Widget? child;
  final VoidCallback onPress;
  final Color? btnColor;
  final Color? titleColor;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final double? fontSize;
  final double? height;
  final double? width;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPress,
    this.btnColor,
    this.child,
    this.titleColor,
    this.padding,
    this.border,
    this.fontSize,
    this.width,
    this.height,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = true;
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: height,
        width: width ?? double.maxFinite,
        padding: padding ?? EdgeInsets.all(10.w).copyWith(top: 12.h, bottom: 12.h),
        decoration: BoxDecoration(
          color: btnColor ?? (darkMode ? Pallete.dividerColor : Pallete.darkBg),
          borderRadius: BorderRadius.circular(30.r),
          border: border,
        ),
        child: Center(
          child: child ??
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor ?? (darkMode ? Pallete.darkBg : Pallete.dividerColor),
                  fontWeight: fontWeight ?? FontWeight.w600,
                  fontSize: fontSize ?? 16.sp,
                ),
              ),
        ),
      ),
    );
  }
}
