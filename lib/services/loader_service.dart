import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/widgets/app_loader.dart';

class LoaderService {
  static final LoaderService _instance = LoaderService._internal();

  factory LoaderService() => _instance;

  LoaderService._internal();

  OverlayEntry? _loaderOverlay;

  void showLoader(BuildContext context, {Widget? child}) {
    if (_loaderOverlay != null) return;

    _loaderOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          if (child == null) ...[
            const ModalBarrier(
              dismissible: false,
              color: Colors.transparent,
            ),
          ],
          Center(
            child: child ??
                (Platform.isIOS
                    ? CupertinoActivityIndicator(
                        radius: 18.r,
                      )
                    : const AppLoader()),
          ),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_loaderOverlay!);
  }

  void hideLoader() {
    _loaderOverlay?.remove();
    _loaderOverlay = null;
  }
}
