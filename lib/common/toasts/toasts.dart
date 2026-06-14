import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../../utils/constants/pallete.dart';
import '../../utils/constants/style_constants.dart';

getToastWidget(BuildContext context, Color color, String msg, bool addBottomMargin, bool error) => Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      margin: addBottomMargin ? EdgeInsets.only(bottom: 150.h) : null,
      width: 0.75.sw,
      height: 60.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: Pallete.darkBg.withValues(alpha: .1),
            offset: const Offset(0, 1),
            blurRadius: 5,
            spreadRadius: 5,
          ),
        ],
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // SvgPicture.asset(error ? CustomAssets.schoolHackLogoWhite : CustomAssets.schoolHackLogoBlack, height: 25.h),
          12.horizontalSpace,
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.h),
              child: Text(
                msg,
                style: StyleConstants.style14500.copyWith(color: error ? Pallete.dividerColor : Pallete.darkBg),
              ),
            ),
          ),
        ],
      ),
    );

showErrorToast(BuildContext context, String msg, [bool addBottomMargin = false]) {
  FToast fToast = FToast()..init(context);
  fToast.init(context);
  fToast.showToast(
    child: getToastWidget(context, Colors.red.shade300, msg, addBottomMargin, true),
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 2),
    positionedToastBuilder: (context, child, gravity) {
      final bottomInset = MediaQuery.of(context).viewInsets.bottom;

      return Positioned(
        bottom: bottomInset + 16.0,
        left: 20.0,
        right: 20.0,
        child: child,
      );
    },
  );
}

showSuccessToast(BuildContext context, String msg, [bool addBottomMargin = false]) {
  FToast fToast = FToast();
  fToast.init(context);
  fToast.showToast(
    child: getToastWidget(context, Pallete.white, msg, addBottomMargin, false),
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 2),
  );
}

showUndoCommentToast(BuildContext context, String msg, Color bgColor, Function(bool) onTapped) {
  FToast fToast = FToast();
  fToast.init(context);
  fToast.showToast(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      margin: EdgeInsets.only(bottom: 150.h),
      width: 0.9.sw,
      // height: 56.h,
      decoration: BoxDecoration(borderRadius: StyleConstants.borderRadius, color: bgColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const RotatedBox(
            quarterTurns: 2,
            child: Icon(Icons.info, color: Pallete.white),
          ),
          SizedBox(
            width: 12.w,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.h),
              child: Text(
                msg,
                style: StyleConstants.style14600.copyWith(color: Pallete.white),
              ),
            ),
          ),
          TextButton(
              onPressed: () => onTapped(true),
              child: const Text(
                'Undo',
                style: TextStyle(decoration: TextDecoration.underline),
              ))
        ],
      ),
    ),
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 4),
  );
}

// showSimpleToast(BuildContext context, String msg) {
//   Fluttertoast.showToast(
//     msg: msg,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.CENTER,
//     timeInSecForIosWeb: 1,
//     fontSize: 12.spMin,
//     textColor: kToastTextColor,
//     backgroundColor: toastBgColor,
//   );
// }
