import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

String removeBulletNumbersAndAsterisks(String str) {
  RegExp regExp = RegExp(r'^\d+\.\s\*\*(.*?)\*\*');
  return str.replaceAllMapped(regExp, (match) => match.group(1) ?? '');
}

String truncateFileName(String fileName) {
  if (fileName.length > 33) {
    int dotIndex = fileName.lastIndexOf('.');
    String extension = fileName.substring(dotIndex - 5);
    String truncatedName = fileName.substring(0, 15);
    return '$truncatedName...$extension';
  } else {
    return fileName;
  }
}

mixin Helpers {
  // void showLoadingDialog({
  //   required BuildContext context,
  //   String? title,
  //   Color? loaderColor,
  // }) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => LoadingDialogWidget(
  //       title: title,
  //       loaderColor: loaderColor,
  //     ),
  //     barrierDismissible: false,
  //   );
  // }

  void showSnackBar(BuildContext context, {required String message, bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: error ? Colors.red : Colors.black,
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}

void launchURL(Uri url) async {
  // final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
    debugPrint("Launching:: $url");
  } else {
    throw 'Something went wrong';
  }
}

Future<bool> shareText({required String text, String subject = "School Hack"}) async {
  final result = await Share.share(text, subject: subject);

  return result.status == ShareResultStatus.success;
}

DateTime stringToDateTime(String dateTimeStr) {
  final dateTime = DateTime.parse(dateTimeStr);
  return dateTime;
}

PopupMenuEntry<String> menuDivider() {
  return PopupMenuDivider(
    height: .5.h,
  );
}
