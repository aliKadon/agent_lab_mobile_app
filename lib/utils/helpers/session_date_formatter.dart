import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


String getRelativeDate(String dateString,BuildContext context) {
  DateTime date = DateTime.parse(dateString);
  DateTime now = DateTime.now();
  Duration difference = now.difference(date);

  if (difference.inDays == 0) {
    return "today";
  } else if (difference.inDays == 1) {
    return "yesterday";
  } else if (difference.inDays < 7) {
    return DateFormat.EEEE().format(date);
  } else {
    return '${difference.inDays} days ago';
  }
}
