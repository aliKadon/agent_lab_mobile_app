import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/constants/pallete.dart';

class ChatShimmer extends ConsumerWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Shimmer(
        gradient: LinearGradient(
          colors:[
                  Pallete.dividerColor.withValues(alpha: .3),
                  Pallete.divider2.withValues(alpha: .1),
                ]

        ),
        period: const Duration(milliseconds: 700),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 30.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.r),
                  ),
                  color: Pallete.primaryLightBG,
                ),
              ),
              5.verticalSpace,
              Container(
                height: 15.h,
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.r),
                  ),
                  color: Pallete.primaryLightBG,
                ),
              ),
              5.verticalSpace,
              Container(
                height: 45.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.r),
                  ),
                  color: Pallete.primaryLightBG,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
