import 'dart:ui';

import 'package:agent_lab/common/widgets/ui/app_snack.dart';
import 'package:agent_lab/common/widgets/ui/primitives.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/providers/ui_providers.dart';
import 'package:agent_lab/screens/chat_screen.dart';
import 'package:agent_lab/screens/home_screen.dart';
import 'package:agent_lab/utils/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  static const _screens = [
    HomeScreen(),
    ChatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Surface API failures instead of swallowing them silently.
    final notifier = ref.read(mainProviderStateProvider.notifier);
    notifier.errorMessages = (msg) => showAppSnack(
          msg.trim().isEmpty ? 'Something went wrong. Please try again.' : msg,
          tone: SnackTone.error,
        );
    notifier.successMessage = (msg) => showAppSnack(msg, tone: SnackTone.success);
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navIndexProvider);
    final activeCount = ref.watch(
      mainProviderStateProvider.select(
        (s) => s.allAgentsList?.agents?.where((a) => a.active == true).length ?? 0,
      ),
    );
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      // Each tab's own Scaffold handles the keyboard; the tab bar steps aside.
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: keyboardOpen
          ? null
          : _GlassTabBar(
              index: index,
              chatBadge: activeCount,
              onSelect: (i) => ref.read(navIndexProvider.notifier).state = i,
            ),
    );
  }
}

class _GlassTabBar extends StatelessWidget {
  final int index;
  final int chatBadge;
  final ValueChanged<int> onSelect;

  const _GlassTabBar({required this.index, required this.chatBadge, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bg.withValues(alpha: 0.82),
            border: const Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.xl, 8, AppSpace.xl, 8),
              child: Row(
                children: [
                  _TabItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Agents',
                    selected: index == 0,
                    onTap: () => onSelect(0),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  _TabItem(
                    icon: Icons.forum_rounded,
                    label: 'Chat',
                    selected: index == 1,
                    badge: chatBadge,
                    onTap: () => onSelect(1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.text : AppColors.textTertiary;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: badge > 0 ? '$label, $badge agents active' : label,
        child: Pressable(
          onTap: onTap,
          pressedScale: 0.94,
          child: AnimatedContainer(
            duration: AppMotion.base,
            curve: AppMotion.emphasized,
            height: 52,
            decoration: BoxDecoration(
              color: selected ? AppColors.surface2 : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: selected ? AppColors.borderStrong : Colors.transparent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (rect) => selected
                          ? AppGradients.brand.createShader(rect)
                          : LinearGradient(colors: [color, color]).createShader(rect),
                      child: Icon(icon, size: 22),
                    ),
                    if (badge > 0)
                      Positioned(
                        right: -9,
                        top: -6,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 17),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.bg, width: 2),
                          ),
                          child: Text(
                            '$badge',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.bg,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: AppMotion.base,
                  style: AppText.label.copyWith(color: color, fontSize: 14),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
