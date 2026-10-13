import 'package:flutter/material.dart';

import '../../../utils/theme/app_tokens.dart';

/// A stable, generative identity for an agent: the same name always produces
/// the same gradient and monogram, so users learn to recognise agents at a glance.
class AgentAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool glow;

  /// When non-null, draws a presence dot (green = in chat).
  final bool? active;

  const AgentAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.glow = false,
    this.active,
  });

  static List<Color> paletteFor(String name) {
    var hash = 0;
    for (final unit in name.toLowerCase().codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return AppGradients.agentPalettes[hash % AppGradients.agentPalettes.length];
  }

  static String monogramFor(String name) {
    final parts = name
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(RegExp(r'[\s_\-.]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = paletteFor(name);
    final radius = size * 0.32;

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: colors.last.withValues(alpha: 0.45),
                  blurRadius: size * 0.6,
                  spreadRadius: -size * 0.1,
                  offset: Offset(0, size * 0.15),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Glossy top highlight gives the tile some depth.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              monogramFor(name),
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );

    if (active == null) return avatar;

    final dot = size * 0.28;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -dot * 0.2,
            bottom: -dot * 0.2,
            child: AnimatedContainer(
              duration: AppMotion.base,
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: active! ? AppColors.success : AppColors.textTertiary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bg, width: dot * 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Agent Lab mark, used as the assistant's avatar in conversations.
class LabMark extends StatelessWidget {
  final double size;
  const LabMark({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGradients.brand,
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.35),
            blurRadius: size * 0.5,
            spreadRadius: -size * 0.1,
          ),
        ],
      ),
      child: Icon(Icons.auto_awesome_rounded, size: size * 0.54, color: Colors.white),
    );
  }
}

/// Overlapping avatars, e.g. "who's in this chat".
class AvatarStack extends StatelessWidget {
  final List<String> names;
  final double size;
  final int max;

  const AvatarStack({super.key, required this.names, this.size = 22, this.max = 4});

  @override
  Widget build(BuildContext context) {
    final shown = names.take(max).toList();
    final overflow = names.length - shown.length;
    final step = size * 0.68;
    final count = shown.length + (overflow > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();

    return SizedBox(
      width: step * (count - 1) + size,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size * 0.36),
                  border: Border.all(color: AppColors.bg, width: 1.5),
                ),
                child: AgentAvatar(name: shown[i], size: size - 3),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: shown.length * step,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface4,
                  borderRadius: BorderRadius.circular(size * 0.36),
                  border: Border.all(color: AppColors.bg, width: 1.5),
                ),
                child: Text(
                  '+$overflow',
                  style: TextStyle(fontSize: size * 0.4, fontWeight: FontWeight.w700, color: AppColors.text),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
