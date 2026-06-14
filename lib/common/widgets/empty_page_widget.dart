import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyPageWidget extends StatelessWidget {
  final String image;
  final String? title;
  final String? subTitle;
  const EmptyPageWidget({super.key,required this.image,this.subTitle,this.title});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 200.h,),
            SizedBox(height: 20.h,),
            Text("$title",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20.sp),),
            SizedBox(height: 10.h,),
            Text("$subTitle",textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16.sp),),

          ],
        ),
      ),
    );
  }
}