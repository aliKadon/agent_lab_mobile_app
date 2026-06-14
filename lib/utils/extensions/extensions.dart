import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../services/error/failure.dart';
import '../constants/constants.dart';



extension NoInternetConnectionHelper on Failure {
  void checkAndTakeAction({required ValueChanged<String>? onError}) async {

    if (this is ForbiddenFailure) {
      onError?.call(message);

    }
    // else {
    onError?.call(message);
    // }
  }
}

extension DateTimeParsing on String {
  String formattedDate() {
    final dateTime = DateTime.parse(this).toLocal();
    final formattedString = DateFormat('dd MMM, yyyy').format(dateTime);
    return formattedString;
  }

  /// Converts an ISO 8601 date string to a formatted date string.
  /// Default format: "dd-MM-yyyy"
  String toFormattedDateString({String format = "dd-MM-yyyy"}) {
    return DateFormat(format).format(DateTime.parse(this).toLocal());
  }

  String toFormattedDateHoursString({String format = "hh:mm a"}) {
    return DateFormat(format).format(DateTime.parse(this).toLocal());
  }
}

extension DMTimeFormat on String {
  String recentMsgTime() {
    try {
      // Parse string to DateTime
      DateTime dateTime = DateTime.parse(this);

      // Get current DateTime
      DateTime now = DateTime.now();

      // Calculate the difference
      Duration difference = now.difference(dateTime);

      if (difference.inHours >= 24) {
        // If older than 24 hours, return date in 'MMM dd, yyyy' format
        return DateFormat('MMM dd, yyyy').format(dateTime);
      } else {
        // If within 24 hours, return time in 'hh:mm a' format
        return DateFormat('hh:mm a').format(dateTime);
      }
    } catch (e) {
      // Handle invalid DateTime formats
      return 'Invalid date format';
    }
  }
}

extension DateTimeExtensions on DateTime {
  String calculateTimeAgo() {
    final difference = DateTime.now().difference(this);

    return difference.inDays >= 365
        ? '${difference.inDays ~/ 365} year${difference.inDays ~/ 365 == 1 ? '' : 's'} ago'
        : difference.inDays >= 30
            ? '${difference.inDays ~/ 30} month${difference.inDays ~/ 30 == 1 ? '' : 's'} ago'
            : difference.inDays >= 1
                ? '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago'
                : difference.inHours >= 1
                    ? '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago'
                    : difference.inMinutes >= 1
                        ? '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago'
                        : 'just now';
  }

  String toCustomTimeFormat() {
    return DateFormat('dd MMM, yyyy').format(this);
  }

  String toGroupInviteTime() {
    return DateFormat('d MMM | hh:mm a').format(this);
  }

  String toCustomEventDateFormat() {
    return DateFormat('d MMMM y').format(this);
  }

  String toCustomNoteDateFormat() {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  String messageTimeFormat() {
    return DateFormat('yyyy-MM-dd | hh:mm a').format(this);
  }

  String toEventTimeRangeString(DateTime start, DateTime end) {
    return "${DateFormat("h a").format(start).split(" ")[0]} ${DateFormat("h a").format(start).split(" ")[1].toLowerCase()} - ${DateFormat("h a").format(end).split(" ")[0]} ${DateFormat("h a").format(end).split(" ")[1].toLowerCase()}";
  }

  String customChatTimeString() {
    return DateFormat.Hm().format(this);
  }

  String toFormattedString() {
    return '${day.toString().padLeft(2, '0')} ${_getMonthName(month)} $year';
  }

  String _getMonthName(int month) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

extension GetJsonFromJWT on String {
  bool isTokenExpired() {
    var splittedString = split('.')[1];
    var normalizedSource = base64Url.normalize(splittedString);
    var jsonString = utf8.decode(base64Url.decode(normalizedSource));

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(0).add(Duration(seconds: jsonDecode(jsonString)['exp'].toInt()));

    final thresholdDate = DateTime.now().add(const Duration(seconds: 30));

    return thresholdDate.isAfter(expirationDate);
  }

  bool isRefreshNeeded() {
    var splittedString = split('.')[1];
    var normalizedSource = base64Url.normalize(splittedString);
    var jsonString = utf8.decode(base64Url.decode(normalizedSource));

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(0).add(Duration(seconds: jsonDecode(jsonString)['exp'].toInt()));

    final thresholdDate = DateTime.now().add(const Duration(minutes: 2));

    return thresholdDate.isAfter(expirationDate);
  }

  String getEmailFromJwt() {
    var splitString = split('.')[1];
    var normalizedSource = base64Url.normalize(splitString);
    var jsonString = utf8.decode(base64Url.decode(normalizedSource));

    final email = jsonDecode(jsonString)['email'].toString();

    return email.isNotEmpty ? email : '';
  }

  String getAudFromJwt() {
    var splitString = split('.')[1];
    var normalizedSource = base64Url.normalize(splitString);
    var jsonString = utf8.decode(base64Url.decode(normalizedSource));

    final audience = jsonDecode(jsonString)['aud'].toString();

    return audience.isNotEmpty ? audience : '';
  }
}

/// This extension create new map of grouped by elements
extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(<K, List<E>>{}, (Map<K, List<E>> map, E element) => map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

/// This extension will convert date to hours ago or days ago
extension GerTimeAgo on String {
  String formatDateStringToHoursOrDaysAgo() {
    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(this);

    // Calculate the time difference
    Duration timeDifference = DateTime.now().toUtc().difference(parsedDate.toUtc());

    // Calculate hours ago or days ago
    int hoursAgo = timeDifference.inHours;
    int daysAgo = timeDifference.inDays;

    if (hoursAgo < 24) {
      // If less than 24 hours, display hours ago
      return '${hoursAgo}h ago';
    } else {
      // If 24 hours or more, display days ago
      return '$daysAgo days ago';
    }
  }

  String capitalizeAndInsertSpaces() {
    List<String> words = split(RegExp(r'(?=[A-Z])|\s+'));
    List<String> capitalizedWords = [];

    for (String word in words) {
      if (word.isNotEmpty) {
        String capitalizedWord = word[0].toUpperCase() + word.substring(1).toLowerCase();
        capitalizedWords.add(capitalizedWord);
      }
    }

    return capitalizedWords.join(' ');
  }

  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

//! EXTENSION FOR HANDLING STATES OF ASYNCSNAPSHOT (STATENOTIFIER)
extension AsyncSnapshotWhen<T> on AsyncSnapshot<T> {
  R when<R>({
    required R Function() none,
    required R Function() waiting,
    required R Function(T data) onData,
    required R Function(Object error, StackTrace stackTrace) error,
  }) {
    switch (connectionState) {
      case ConnectionState.none:
        return none();
      case ConnectionState.waiting:
        return waiting();
      case ConnectionState.active:
      case ConnectionState.done:
        if (hasError) {
          return error(this.error!, stackTrace!);
        } else if (hasData) {
          return onData(data as T);
        } else {
          return none();
        }
    }
  }
}

extension TimeOfDayExtension on TimeOfDay {
  String formattedTime() {
    final hours = hourOfPeriod.toString().padLeft(2, '0');
    final minutes = minute.toString().padLeft(2, '0');
    final amPm = period == DayPeriod.am ? 'am' : 'pm';
    return '$hours:$minutes$amPm';
  }
}

extension ColorExtension on Color {
  MaterialStateProperty<Color?> get asMaterialStateProperty {
    return MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return withOpacity(0.5);
        }
        return this;
      },
    );
  }
}

//! extensions on string to check it it's empty or null & vice versa
extension StringExtensions on String? {
  String orEmpty() => this?.isNotEmpty == true ? this! : '';

  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

//! extension on list to check it it's empty or null
extension NullableListExtension<T> on List<T>? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}

//! convert bytes to mbs & kbs (int)
extension ByteConversionFromInt on int {
  String toReadableSize() {
    if (this >= 1024 * 1024) {
      return "${(this / (1024 * 1024)).toStringAsFixed(1)} MB";
    } else {
      return "${(this / 1024).toStringAsFixed(1)} KB";
    }
  }
}

//! convert bytes to mbs & kbs (num)
extension ByteConversionFromNum on num {
  String toReadableSize() {
    if (this >= 1024 * 1024) {
      return "${(this / (1024 * 1024)).toStringAsFixed(1)} MB";
    } else {
      return "${(this / 1024).toStringAsFixed(1)} KB";
    }
  }
}

//! extension for checking app mode (light / dark)
// extension ThemeExtensionsOnWidgetRef on WidgetRef {
//   bool get isDarkMode => watch(themeStateProvider) == ThemeEnum.dark;
//
//   Color get primaryForeground => isDarkMode ? Pallete.dividerColor : Pallete.darkBg;
//
//   Color get secondaryBackground => isDarkMode ? Pallete.darkBg : Pallete.dividerColor;
// }

//! extension for checking app mode (light / dark)

// extension ThemeExtensionsOnRef on Ref {
//   bool get isDarkMode => watch(themeStateProvider) == ThemeEnum.dark;
//
//   Color get primaryForeground => isDarkMode ? Pallete.dividerColor : Pallete.darkBg;
//
//   Color get secondaryBackground => isDarkMode ? Pallete.darkBg : Pallete.dividerColor;
// }
