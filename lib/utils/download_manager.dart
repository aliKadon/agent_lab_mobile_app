import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/widgets/popup.dart';


class DownloadManager {
  static Future<void> downloadFile({
    required BuildContext context,
    required String url,
    required WidgetRef ref,
  }) async {
    FileDownloader.downloadFile(
      notificationType: NotificationType.all,
      url: url,
      onDownloadError: (errorMessage) {
        debugPrint("error message for downloading : $errorMessage");
        popUpProgressError(
          context: context,
          ref: ref,
        );
      },
      onDownloadCompleted: (path) {
        // File file = File(path);
        debugPrint("path file : $path");
        popUpProgressCompleted(context: context, darkMode: true);
      },
    );
  }
}
