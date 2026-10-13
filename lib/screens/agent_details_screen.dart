import 'package:agent_lab/common/widgets/ui/agent_avatar.dart';
import 'package:agent_lab/common/widgets/ui/app_snack.dart';
import 'package:agent_lab/common/widgets/ui/primitives.dart';
import 'package:agent_lab/models/get_agnts_details_with_code_source_model.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/screens/widgets/agent_actions.dart';
import 'package:agent_lab/utils/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AgentDetailsScreen extends ConsumerStatefulWidget {
  final String agentId;
  final String agentName;

  const AgentDetailsScreen({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  ConsumerState<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends ConsumerState<AgentDetailsScreen> {
  bool _toggling = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref.read(mainProviderStateProvider.notifier).getAgentDetails(agentId: widget.agentId);
    if (mounted && !_loaded) setState(() => _loaded = true);
  }

  Future<void> _toggleChat(bool active) async {
    setState(() => _toggling = true);
    await AgentActions.toggleChat(ref, name: widget.agentName, currentlyActive: active);
    if (mounted) setState(() => _toggling = false);
  }

  Future<void> _delete() async {
    final deleted = await AgentActions.confirmAndDelete(context, ref, id: widget.agentId, name: widget.agentName);
    if (deleted && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainProviderStateProvider);
    // Ignore stale details left over from a previously opened agent.
    final fetched = state.selectedAgentDetails;
    final matches = fetched != null &&
        (fetched.index?.toString() == widget.agentId || (fetched.index == null && fetched.name == widget.agentName));
    final details = matches ? fetched : null;
    final loading = state.isLoadingDetails || (!_loaded && details == null);

    // The list is the source of truth for chat membership; it updates instantly on toggle.
    final listAgent = state.allAgentsList?.agents?.where((a) => a.index?.toString() == widget.agentId).firstOrNull;
    final active = listAgent?.active ?? details?.active ?? false;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.brand,
        backgroundColor: AppColors.surface2,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.bg.withValues(alpha: 0.92),
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  size: 36,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpace.md),
                  child: CircleIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete agent',
                    size: 36,
                    color: AppColors.danger,
                    onPressed: _delete,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _Hero(
                agentId: widget.agentId,
                name: details?.name ?? widget.agentName,
                active: active,
                method: details?.method ?? listAgent?.method,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.lg, AppSpace.gutter, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: active
                          ? GhostButton(
                              label: 'Leave chat',
                              icon: Icons.logout_rounded,
                              color: AppColors.warning,
                              loading: _toggling,
                              onPressed: () => _toggleChat(true),
                            )
                          : GradientButton(
                              label: 'Add to chat',
                              icon: Icons.add_comment_rounded,
                              loading: _toggling,
                              onPressed: () => _toggleChat(false),
                            ),
                    ),
                    if (active) ...[
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: GradientButton(
                          label: 'Open chat',
                          icon: Icons.forum_rounded,
                          onPressed: () => AgentActions.openChat(ref, context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (loading)
              const SliverToBoxAdapter(child: _DetailsSkeleton())
            else if (details == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Couldn\'t load details',
                  message: 'Check your connection and try again.',
                  accent: AppColors.warning,
                  action: GhostButton(label: 'Retry', icon: Icons.refresh_rounded, expand: false, height: 44, onPressed: _load),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  AppSpace.xl,
                  AppSpace.gutter,
                  MediaQuery.paddingOf(context).bottom + AppSpace.xxl,
                ),
                sliver: SliverList.list(
                  children: [
                    if ((details.description ?? '').isNotEmpty) ...[
                      const SectionLabel('About'),
                      Text(details.description!, style: AppText.body.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: AppSpace.xl),
                    ],
                    const SectionLabel('Specs'),
                    _SpecsGrid(details: details),
                    if ((details.file_path ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppSpace.xl),
                      const SectionLabel('Location'),
                      _CopyableRow(icon: Icons.folder_open_rounded, value: details.file_path!),
                    ],
                    if ((details.source_code ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppSpace.xl),
                      _SourceCode(code: details.source_code!),
                    ],
                  ]
                      .animate(interval: 40.ms)
                      .fadeIn(duration: AppMotion.slow)
                      .moveY(begin: 10, end: 0, curve: AppMotion.emphasized),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final String agentId;
  final String name;
  final bool active;
  final String? method;

  const _Hero({required this.agentId, required this.name, required this.active, this.method});

  @override
  Widget build(BuildContext context) {
    final colors = AgentAvatar.paletteFor(name);
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.xs, AppSpace.gutter, 0),
      decoration: BoxDecoration(gradient: AppGradients.aurora(colors.first)),
      child: Column(
        children: [
          Hero(
            tag: 'agent-avatar-$agentId',
            child: AgentAvatar(name: name, size: 92, glow: true),
          ),
          const SizedBox(height: AppSpace.md),
          Text(name, style: AppText.title1, textAlign: TextAlign.center),
          const SizedBox(height: AppSpace.xs),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(active: active),
              if ((method ?? '').isNotEmpty) Tag(label: method!, icon: Icons.memory_rounded, color: AppColors.brand),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  final GetAgentsDetailsWithCodeSource details;
  const _SpecsGrid({required this.details});

  @override
  Widget build(BuildContext context) {
    final specs = [
      (Icons.memory_rounded, 'Method', details.method),
      (Icons.input_rounded, 'Input', details.input_format),
      (Icons.sync_rounded, 'Synced', friendlyTimestamp(details.synced_at)),
      (Icons.tag_rounded, 'ID', details.index?.toString()),
    ].where((s) => (s.$3 ?? '').isNotEmpty).toList();

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - AppSpace.xs) / 2;
        return Wrap(
          spacing: AppSpace.xs,
          runSpacing: AppSpace.xs,
          children: [
            for (final s in specs)
              SizedBox(
                width: w,
                child: Surface(
                  padding: const EdgeInsets.all(AppSpace.sm + 2),
                  radius: AppRadius.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(s.$1, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 6),
                          Text(s.$2, style: AppText.caption.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(s.$3!, style: AppText.label, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CopyableRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _CopyableRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      pressedScale: 0.98,
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        showAppSnack('Path copied', tone: SnackTone.success);
      },
      child: Surface(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: AppSpace.sm + 2),
        radius: AppRadius.md,
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppSpace.sm),
            Expanded(child: Text(value, style: AppText.mono.copyWith(color: AppColors.textSecondary))),
            const SizedBox(width: AppSpace.xs),
            const Icon(Icons.copy_rounded, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SourceCode extends StatefulWidget {
  final String code;
  const _SourceCode({required this.code});

  @override
  State<_SourceCode> createState() => _SourceCodeState();
}

class _SourceCodeState extends State<_SourceCode> {
  static const _collapsedLines = 18;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final lines = widget.code.split('\n');
    final canCollapse = lines.length > _collapsedLines;
    final shown = _expanded || !canCollapse ? lines : lines.take(_collapsedLines).toList();
    final gutterWidth = (lines.length.toString().length * 8.0) + 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          'Source code',
          trailing: Text('${lines.length} lines', style: AppText.caption.copyWith(color: AppColors.textTertiary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C12),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Editor-style title bar
              Container(
                padding: const EdgeInsets.fromLTRB(AppSpace.md, 10, 6, 10),
                decoration: const BoxDecoration(
                  color: AppColors.surface1,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    for (final c in const [Color(0xFFFF5F57), Color(0xFFFEBC2E), Color(0xFF28C840)])
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(color: c.withValues(alpha: 0.85), shape: BoxShape.circle),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.code));
                        showAppSnack('Source code copied', tone: SnackTone.success);
                      },
                      icon: const Icon(Icons.copy_rounded, size: 15),
                      label: const Text('Copy'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: gutterWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < shown.length; i++)
                            Text('${i + 1}', style: AppText.mono.copyWith(color: AppColors.textTertiary.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    SelectableText(
                      shown.join('\n'),
                      style: AppText.mono.copyWith(color: const Color(0xFFD7D7E5)),
                    ),
                    const SizedBox(width: AppSpace.md),
                  ],
                ),
              ),
              if (canCollapse)
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _expanded ? 'Show less' : 'Show all ${lines.length} lines',
                          style: AppText.label.copyWith(color: AppColors.brand),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: AppMotion.base,
                          child: const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.brand),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.xl, AppSpace.gutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 60, height: 10),
          SizedBox(height: AppSpace.sm),
          Skeleton(height: 14),
          SizedBox(height: 8),
          Skeleton(height: 14),
          SizedBox(height: 8),
          Skeleton(width: 200, height: 14),
          SizedBox(height: AppSpace.xl),
          Row(
            children: [
              Expanded(child: Skeleton(height: 64, radius: AppRadius.md)),
              SizedBox(width: AppSpace.xs),
              Expanded(child: Skeleton(height: 64, radius: AppRadius.md)),
            ],
          ),
          SizedBox(height: AppSpace.xl),
          Skeleton(height: 220, radius: AppRadius.md),
        ],
      ),
    );
  }
}
