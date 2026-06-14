import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';


class ImageSourcePicker {
  static Future<File?> pickFile(ImageSource imageSource) async {
    ImagePicker picker = ImagePicker();
    final hasPermission = await _ensurePermission(imageSource);
    if (!hasPermission) {
      debugPrint('Image picking aborted because the required permission was not granted.');
      return null;
    }
    try {
      final XFile? image =
          await picker.pickImage(source: imageSource, imageQuality: 50);
      if (image == null) return null;

      return File(image.path);
    } on PlatformException catch (error) {
      if (error.code == 'camera_access_denied' ||
          error.code == 'camera_access_restricted' ||
          error.code == 'photo_access_denied') {
        debugPrint(
            'Image picking failed due to missing permissions (${error.code}).');
      } else {
        debugPrint('Image picking failed: $error');
      }
      return null;
    }
  }

  static Future<bool> _ensurePermission(ImageSource source) async {
    if (!(Platform.isAndroid || Platform.isIOS)) return true;

    final Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      permission = Platform.isIOS ? Permission.photos : Permission.storage;
    }

    final status = await permission.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      debugPrint('Permission $permission permanently denied.');
      return false;
    }

    final requestResult = await permission.request();
    if (requestResult.isGranted || requestResult.isLimited) {
      return true;
    }

    debugPrint('Permission $permission denied.');
    return false;
  }
}
