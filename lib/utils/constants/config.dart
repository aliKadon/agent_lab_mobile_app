import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class Config {
  static String? _googleServerClientId;
  static String? _pusherKeyDev;
  static String? _pusherCluster;
  static String? _pusherKeyProd;
  static String? _oneSignalAppIdProd;
  static String? _oneSignalAppIdDev;

  static Future<void> loadConfig() async {
    final configString = await rootBundle.loadString(
      'assets/configs/local_config.json',
    );
    final Map<String, dynamic> configData = jsonDecode(configString);
    _googleServerClientId = configData['googleServerClientId'];
    _pusherKeyDev = configData["pusherKeyDev"];
    _pusherKeyProd = configData["pusherKeyProd"];
    _pusherCluster = configData["pusherCluster"];
    _oneSignalAppIdProd = configData["one_signal_app_id_prod"];
    _oneSignalAppIdDev = configData["one_signal_app_id_stage"];
  }

  static String get googleServerClientId => _googleServerClientId ?? '';
  static String get pusherKey {
    if (kReleaseMode) {
      // Production
      // return _pusherKeyDev ?? '';
      return _pusherKeyProd ?? '';
    } else {
      // Dev
      // return _pusherKeyProd ?? '';
      return _pusherKeyDev ?? '';
    }
  }
  static String get pusherCluster => _pusherCluster ?? '';

  static String get oneSignalAppId {
    if (kReleaseMode) {
      // Production
      // return _pusherKeyDev ?? '';
      return _oneSignalAppIdProd ?? '';
    } else {
      // Dev
      // return _pusherKeyProd ?? '';
      return _oneSignalAppIdDev ?? '';
    }
  }
}




//pusher key dev : //  pusher key dev : "1d405f12c81e71e1c911"
//pusher key prod :