import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/theme/app_tokens.dart';

/// Root messenger so feedback can be shown from anywhere (including providers'
/// callbacks) without needing a BuildContext that's still mounted.
final GlobalKey<ScaffoldMessengerState> rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum SnackTone { info, success, error }

void showAppSnack(String message, {SnackTone tone = SnackTone.info, SnackBarAction? action}) {
  final messenger = rootMessengerKey.currentState;
  if (messenger == null) return;

  final (IconData icon, Color color) = switch (tone) {
    SnackTone.success => (Icons.check_circle_rounded, AppColors.success),
    SnackTone.error => (Icons.error_rounded, AppColors.danger),
    SnackTone.info => (Icons.info_rounded, AppColors.info),
  };

  if (tone == SnackTone.error) HapticFeedback.heavyImpact();

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        action: action,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: AppText.label)),
          ],
        ),
      ),
    );
}
