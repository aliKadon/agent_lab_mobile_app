import 'package:agent_lab/common/widgets/ui/agent_avatar.dart';
import 'package:agent_lab/common/widgets/ui/app_snack.dart';
import 'package:agent_lab/common/widgets/ui/primitives.dart';
import 'package:agent_lab/models/all_agents_list_model.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/providers/ui_providers.dart';
import 'package:agent_lab/screens/agent_details_screen.dart';
import 'package:agent_lab/utils/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Agent operations shared by the Agents list and the Agent details screen,
/// so both places behave (and give feedback) identically.
class AgentActions {
  const AgentActions._();

  static Future<void> toggleChat(WidgetRef ref, {required String name, required bool currentlyActive}) async {
    final notifier = ref.read(mainProviderStateProvider.notifier);
    if (currentlyActive) {
      await notifier.removeAgentFromChat(agentName: name);
    } else {
      await notifier.addAgentToChat(agentName: name);
    }
    final nowActive = ref
            .read(mainProviderStateProvider)
            .allAgentsList
            ?.agents
            ?.firstWhere((a) => a.name == name, orElse: () => AgentModel())
            .active ==
        true;
    if (nowActive == currentlyActive) return; // request failed; error snack already shown
    showAppSnack(
      nowActive ? '$name joined the chat' : '$name left the chat',
      tone: nowActive ? SnackTone.success : SnackTone.info,
      action: nowActive
          ? SnackBarAction(
              label: 'Open chat',
              textColor: AppColors.brand,
              onPressed: () => openChat(ref),
            )
          : null,
    );
  }

  /// Returns true when the agent was deleted.
  static Future<bool> confirmAndDelete(BuildContext context, WidgetRef ref, {required String id, required String name}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => _DeleteDialog(name: name),
    );
    if (confirmed != true) return false;

    final before = ref.read(mainProviderStateProvider).allAgentsList?.agents?.length ?? 0;
    await ref.read(mainProviderStateProvider.notifier).deleteAgent(agentId: id);
    final after = ref.read(mainProviderStateProvider).allAgentsList?.agents?.length ?? 0;
    if (after < before) {
      showAppSnack('Deleted $name', tone: SnackTone.success);
      return true;
    }
    return false;
  }

  static void openDetails(BuildContext context, AgentModel agent) {
    if (agent.index == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AgentDetailsScreen(
          agentId: agent.index!.toString(),
          agentName: agent.name ?? 'Agent',
        ),
      ),
    );
  }

  static void openChat(WidgetRef ref, [BuildContext? context]) {
    ref.read(navIndexProvider.notifier).state = 1;
    if (context != null) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  static Future<void> showSheet(BuildContext context, WidgetRef ref, AgentModel agent) {
    final name = agent.name ?? 'Agent';
    final active = agent.active == true;
    return showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, AppSpace.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  AgentAvatar(name: name, size: 44, active: active),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppText.title3, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        StatusPill(active: active),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              _SheetAction(
                icon: Icons.info_outline_rounded,
                label: 'View details',
                onTap: () {
                  Navigator.pop(sheetCtx);
                  openDetails(context, agent);
                },
              ),
              _SheetAction(
                icon: active ? Icons.logout_rounded : Icons.add_comment_rounded,
                label: active ? 'Remove from chat' : 'Add to chat',
                color: active ? AppColors.warning : AppColors.success,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  toggleChat(ref, name: name, currentlyActive: active);
                },
              ),
              _SheetAction(
                icon: Icons.delete_outline_rounded,
                label: 'Delete agent',
                color: AppColors.danger,
                onTap: () {
                  Navigator.pop(sheetCtx);
                  if (agent.index != null) {
                    confirmAndDelete(context, ref, id: agent.index!.toString(), name: name);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetAction({required this.icon, required this.label, required this.onTap, this.color = AppColors.text});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        margin: const EdgeInsets.only(top: AppSpace.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpace.sm),
            Text(label, style: AppText.label.copyWith(color: color, fontSize: 15)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  final String name;
  const _DeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
              child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 28),
            ),
            const SizedBox(height: AppSpace.md),
            Text('Delete $name?', style: AppText.title2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.xs),
            const Text(
              'This permanently removes the agent and its source code. This can\'t be undone.',
              style: AppText.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.xl),
            Row(
              children: [
                Expanded(
                  child: GhostButton(label: 'Cancel', height: 48, onPressed: () => Navigator.pop(context, false)),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Pressable(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text('Delete', style: AppText.label.copyWith(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "3 minutes ago" style formatting for API timestamps, tolerant of bad input.
String friendlyTimestamp(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  final date = parsed.toLocal();
  final diff = DateTime.now().difference(date);
  if (diff.isNegative) return DateFormat('d MMM yyyy, HH:mm').format(date);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} h ago';
  if (diff.inDays < 7) return '${diff.inDays} d ago';
  return DateFormat('d MMM yyyy').format(date);
}
