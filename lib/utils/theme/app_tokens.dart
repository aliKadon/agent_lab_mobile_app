import 'package:flutter/material.dart';

/// Agent Lab design tokens.
///
/// One dark "ink" canvas, layered surfaces separated by hairlines rather than
/// shadows, and a single signature violet→magenta gradient reserved for the
/// moments that matter (primary actions, live status, the user's own voice).
@immutable
class AppColors {
  const AppColors._();

  // Canvas & surfaces (each step is a little lighter than the one below it)
  static const Color bg = Color(0xFF08080C);
  static const Color surface1 = Color(0xFF101016);
  static const Color surface2 = Color(0xFF16161E);
  static const Color surface3 = Color(0xFF1E1E28);
  static const Color surface4 = Color(0xFF282834);

  // Hairlines
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x24FFFFFF);

  // Text
  static const Color text = Color(0xFFF4F4F8);
  static const Color textSecondary = Color(0xFFA3A3B8);
  static const Color textTertiary = Color(0xFF6C6C82);

  // Brand
  static const Color brand = Color(0xFF9B6BFF);
  static const Color brandDeep = Color(0xFF6D4AFF);
  static const Color brandSoft = Color(0x269B6BFF);
  static const Color magenta = Color(0xFFE266D6);
  static const Color cyan = Color(0xFF4FD8F0);

  // Semantic
  static const Color success = Color(0xFF3DDC97);
  static const Color successSoft = Color(0x1F3DDC97);
  static const Color warning = Color(0xFFFFC452);
  static const Color warningSoft = Color(0x1FFFC452);
  static const Color danger = Color(0xFFFF6B7A);
  static const Color dangerSoft = Color(0x1FFF6B7A);
  static const Color info = Color(0xFF5AB8FF);
  static const Color infoSoft = Color(0x1F5AB8FF);
}

@immutable
class AppGradients {
  const AppGradients._();

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.brandDeep, AppColors.brand, AppColors.magenta],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient userBubble = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D4AFF), Color(0xFF8A5CFF)],
  );

  /// Soft aurora wash used behind hero areas.
  static RadialGradient aurora([Color color = AppColors.brand]) => RadialGradient(
        center: const Alignment(-0.6, -1.0),
        radius: 1.2,
        colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
      );

  /// Gradient pairs used to give every agent a stable, unique identity.
  static const List<List<Color>> agentPalettes = [
    [Color(0xFF6D4AFF), Color(0xFFE266D6)],
    [Color(0xFF00B4D8), Color(0xFF6D4AFF)],
    [Color(0xFFFF8A5B), Color(0xFFE2366B)],
    [Color(0xFF3DDC97), Color(0xFF00A3C4)],
    [Color(0xFFFFC452), Color(0xFFFF6B7A)],
    [Color(0xFF8E7CFF), Color(0xFF4FD8F0)],
    [Color(0xFFB66BFF), Color(0xFF5A6BFF)],
    [Color(0xFF2BD4A4), Color(0xFF8BE04E)],
  ];
}

@immutable
class AppRadius {
  const AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

@immutable
class AppSpace {
  const AppSpace._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal page gutter.
  static const double gutter = 20;
}

@immutable
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
}

/// Type scale. Sizes are logical pixels so text respects the user's
/// accessibility text-scale without being double-scaled by ScreenUtil.
@immutable
class AppText {
  const AppText._();

  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: AppColors.text,
  );
  static const TextStyle title1 = TextStyle(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.text,
  );
  static const TextStyle title2 = TextStyle(
    fontSize: 19,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.text,
  );
  static const TextStyle title3 = TextStyle(
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.text,
  );
  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.textTertiary,
  );
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['Menlo', 'Courier'],
    fontSize: 12.5,
    height: 1.55,
    color: AppColors.text,
  );
}
