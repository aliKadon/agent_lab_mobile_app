import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../utils/constants/style_constants.dart';

void popUpProgressError({required BuildContext context, required WidgetRef ref}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: 200.w,
          height: 250.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 100.h,
                color: Colors.red,
              ),
              Text("Something went wrong", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16.sp)),
            ],
          ),
        ),
      );
    },
  );
}

void popUpProgressCompleted({required BuildContext context, required bool darkMode}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: SizedBox(
          width: 200.w,
          height: 250.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.done_outline,
                color: Colors.green,
                size: 100.h,
              ),
              Text("successfully downloaded", style: StyleConstants.style16600.copyWith()),
            ],
          ),
        ),
      );
    },
  );
}



void popUpLoader({required BuildContext context}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(170.w), // or some smaller EdgeInsets
        child: SizedBox(
          width: 20.h, // or 20.w, if ScreenUtil is set up
          height: 70.h, // or 20.h
          // color: Colors.white,
          child: Center(
            child: Platform.isIOS
                ? CupertinoActivityIndicator(
                    radius: 30.r,
                  )
                : const CircularProgressIndicator(
                    color: Colors.black,
                  ),
          ),
        ),
      );
    },
  );
}








