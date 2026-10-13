import 'package:agent_lab/common/widgets/ui/agent_avatar.dart';
import 'package:agent_lab/common/widgets/ui/primitives.dart';
import 'package:agent_lab/models/all_agents_list_model.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/screens/create_agent_screen.dart';
import 'package:agent_lab/screens/widgets/agent_actions.dart';
import 'package:agent_lab/utils/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum _AgentFilter { all, inChat, idle }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  _AgentFilter _filter = _AgentFilter.all;
  String _query = '';
  bool _fabExtended = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainProviderStateProvider.notifier).getAllAgents(forceReplace: true);
    });
    _scrollController.addListener(() {
      final dir = _scrollController.position.userScrollDirection;
      if (dir == ScrollDirection.reverse && _fabExtended) setState(() => _fabExtended = false);
      if (dir == ScrollDirection.forward && !_fabExtended) setState(() => _fabExtended = true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => ref.read(mainProviderStateProvider.notifier).getAllAgents(forceReplace: true);

  void _openCreate() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateAgentScreen()));
  }

  List<AgentModel> _visible(List<AgentModel> agents) {
    final q = _query.trim().toLowerCase();
    return agents.where((a) {
      final active = a.active == true;
      if (_filter == _AgentFilter.inChat && !active) return false;
      if (_filter == _AgentFilter.idle && active) return false;
      if (q.isEmpty) return true;
      return (a.name ?? '').toLowerCase().contains(q) ||
          (a.description ?? '').toLowerCase().contains(q) ||
          (a.method ?? '').toLowerCase().contains(q);
    }).toList();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 5) return 'Working late';
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainProviderStateProvider);
    final agents = state.allAgentsList?.agents ?? const <AgentModel>[];
    final activeCount = agents.where((a) => a.active == true).length;
    final visible = _visible(agents);
    final initialLoading = state.isLoading && agents.isEmpty;

    return Scaffold(
      floatingActionButton: agents.isEmpty
          ? null
          : _CreateFab(extended: _fabExtended, onPressed: _openCreate),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.brand,
        backgroundColor: AppColors.surface2,
        edgeOffset: MediaQuery.paddingOf(context).top,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(
                greeting: _greeting,
                total: agents.length,
                active: activeCount,
                loading: initialLoading,
                filter: _filter,
                onFilter: (f) => setState(() => _filter = _filter == f ? _AgentFilter.all : f),
              ),
            ),
            if (initialLoading)
              const _SkeletonList()
            else if (agents.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyLab(onCreate: _openCreate),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, AppSpace.md),
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),
              if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No matches',
                    message: _query.isNotEmpty
                        ? 'No agents match "$_query".'
                        : _filter == _AgentFilter.inChat
                            ? 'None of your agents are in the chat yet. Flip the switch on an agent to add it.'
                            : 'Every agent is already in the chat.',
                    action: GhostButton(
                      label: 'Clear filters',
                      expand: false,
                      height: 44,
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                          _filter = _AgentFilter.all;
                        });
                      },
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, 120),
                  sliver: SliverList.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpace.sm),
                    itemBuilder: (context, i) => _AgentCard(
                      key: ValueKey(visible[i].index ?? visible[i].name),
                      agent: visible[i],
                    )
                        .animate()
                        .fadeIn(delay: (40 * i.clamp(0, 10)).ms, duration: AppMotion.slow)
                        .moveY(begin: 14, end: 0, curve: AppMotion.emphasized),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String greeting;
  final int total;
  final int active;
  final bool loading;
  final _AgentFilter filter;
  final ValueChanged<_AgentFilter> onFilter;

  const _Header({
    required this.greeting,
    required this.total,
    required this.active,
    required this.loading,
    required this.filter,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: BoxDecoration(gradient: AppGradients.aurora()),
      padding: EdgeInsets.fromLTRB(AppSpace.gutter, top + AppSpace.lg, AppSpace.gutter, AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting.toUpperCase(), style: AppText.overline.copyWith(color: AppColors.brand)),
          const SizedBox(height: 6),
          const Text('Your agent lab', style: AppText.display),
          const SizedBox(height: 6),
          Text(
            total == 0 && !loading
                ? 'Build specialised AI agents from a plain-English description.'
                : 'Manage your agents and choose who joins the conversation.',
            style: AppText.bodySecondary,
          ),
          if (total > 0 || loading) ...[
            const SizedBox(height: AppSpace.lg),
            Row(
              children: [
                _StatTile(
                  label: 'Agents',
                  value: loading ? null : total,
                  icon: Icons.grid_view_rounded,
                  color: AppColors.brand,
                  selected: filter == _AgentFilter.all,
                  onTap: () => onFilter(_AgentFilter.all),
                ),
                const SizedBox(width: AppSpace.xs),
                _StatTile(
                  label: 'In chat',
                  value: loading ? null : active,
                  icon: Icons.bolt_rounded,
                  color: AppColors.success,
                  selected: filter == _AgentFilter.inChat,
                  onTap: () => onFilter(_AgentFilter.inChat),
                ),
                const SizedBox(width: AppSpace.xs),
                _StatTile(
                  label: 'Idle',
                  value: loading ? null : total - active,
                  icon: Icons.pause_circle_outline_rounded,
                  color: AppColors.textSecondary,
                  selected: filter == _AgentFilter.idle,
                  onTap: () => onFilter(_AgentFilter.idle),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Doubles as a stat and a filter: tap "In chat" to see only those agents.
class _StatTile extends StatelessWidget {
  final String label;
  final int? value;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: 'Filter: $label, ${value ?? 0}',
        child: Pressable(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppMotion.base,
            curve: AppMotion.emphasized,
            padding: const EdgeInsets.all(AppSpace.sm),
            decoration: BoxDecoration(
              color: selected ? color.withValues(alpha: 0.1) : AppColors.surface1,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: selected ? color.withValues(alpha: 0.45) : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(height: AppSpace.xs),
                value == null
                    ? const Skeleton(width: 28, height: 22)
                    : TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: value!),
                        duration: AppMotion.slow,
                        builder: (_, v, __) => Text('$v', style: AppText.title1.copyWith(height: 1)),
                      ),
                const SizedBox(height: 2),
                Text(label, style: AppText.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      textInputAction: TextInputAction.search,
      style: AppText.body,
      decoration: InputDecoration(
        hintText: 'Search agents',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
        suffixIcon: ValueListenableBuilder(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

// ─── Agent card ────────────────────────────────────────────────────────────

class _AgentCard extends ConsumerStatefulWidget {
  final AgentModel agent;
  const _AgentCard({super.key, required this.agent});

  @override
  ConsumerState<_AgentCard> createState() => _AgentCardState();
}

class _AgentCardState extends ConsumerState<_AgentCard> {
  bool _busy = false;

  Future<void> _toggle() async {
    final name = widget.agent.name;
    if (name == null || _busy) return;
    setState(() => _busy = true);
    await AgentActions.toggleChat(ref, name: name, currentlyActive: widget.agent.active == true);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final agent = widget.agent;
    final name = agent.name ?? 'Untitled agent';
    final active = agent.active == true;
    final description = agent.description?.trim();

    return Semantics(
      button: true,
      label: '$name, ${active ? 'in chat' : 'idle'}. Long press for options.',
      child: Pressable(
        pressedScale: 0.985,
        onTap: () => AgentActions.openDetails(context, agent),
        onLongPress: () => AgentActions.showSheet(context, ref, agent),
        child: AnimatedContainer(
          duration: AppMotion.slow,
          curve: AppMotion.emphasized,
          padding: const EdgeInsets.all(AppSpace.md),
          decoration: BoxDecoration(
            color: AppColors.surface1,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: active ? AppColors.success.withValues(alpha: 0.28) : AppColors.border,
            ),
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.success.withValues(alpha: 0.07), AppColors.surface1],
                    stops: const [0, 0.55],
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'agent-avatar-${agent.index}',
                child: AgentAvatar(name: name, size: 48, active: active),
              ),
              const SizedBox(width: AppSpace.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.title3, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      description == null || description.isEmpty ? 'No description' : description,
                      style: AppText.bodySecondary.copyWith(fontSize: 13.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((agent.method ?? '').isNotEmpty || (agent.input_format ?? '').isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if ((agent.method ?? '').isNotEmpty)
                            Tag(label: agent.method!, icon: Icons.memory_rounded, color: AppColors.brand),
                          if ((agent.input_format ?? '').isNotEmpty)
                            Tag(label: agent.input_format!, icon: Icons.input_rounded),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.xs),
              _ChatToggle(active: active, busy: _busy, onTap: _toggle, name: name),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatToggle extends StatelessWidget {
  final bool active;
  final bool busy;
  final VoidCallback onTap;
  final String name;

  const _ChatToggle({required this.active, required this.busy, required this.onTap, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 32,
          child: busy
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Semantics(
                  label: active ? 'Remove $name from chat' : 'Add $name to chat',
                  child: Transform.scale(
                    scale: 0.82,
                    child: Switch(
                      value: active,
                      onChanged: (_) => onTap(),
                      activeTrackColor: AppColors.success,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
        ),
        Text(
          active ? 'In chat' : 'Idle',
          style: AppText.caption.copyWith(
            fontSize: 10.5,
            color: active ? AppColors.success : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

// ─── Loading / empty / fab ────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.gutter),
      sliver: SliverList.separated(
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpace.sm),
        itemBuilder: (_, __) => const Surface(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 48, height: 48, radius: 15),
              SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 140, height: 16),
                    SizedBox(height: 8),
                    Skeleton(height: 12),
                    SizedBox(height: 6),
                    Skeleton(width: 180, height: 12),
                    SizedBox(height: 12),
                    Skeleton(width: 90, height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyLab extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyLab({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.md, AppSpace.gutter, 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Surface(
            padding: const EdgeInsets.all(AppSpace.xl),
            radius: AppRadius.xl,
            borderColor: AppColors.brand.withValues(alpha: 0.3),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.brand.withValues(alpha: 0.14), AppColors.surface1],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LabMark(size: 48)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 2400.ms, color: Colors.white24),
                const SizedBox(height: AppSpace.lg),
                const Text('Create your first agent', style: AppText.title1),
                const SizedBox(height: AppSpace.xs),
                const Text(
                  'Describe what you need in plain words. The lab finds the right model, asks a few questions, and builds the agent for you.',
                  style: AppText.bodySecondary,
                ),
                const SizedBox(height: AppSpace.lg),
                ...const [
                  (Icons.edit_note_rounded, 'Describe the job'),
                  (Icons.hub_rounded, 'Pick a model'),
                  (Icons.rocket_launch_rounded, 'Chat with your agent'),
                ].indexed.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.xs),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.surface3,
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                              child: Icon(e.$2.$1, size: 16, color: AppColors.brand),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Expanded(child: Text('${e.$1 + 1}. ${e.$2.$2}', style: AppText.label)),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: AppSpace.md),
                GradientButton(label: 'Create agent', icon: Icons.auto_awesome_rounded, onPressed: onCreate),
              ],
            ),
          ).animate().fadeIn(duration: AppMotion.slow).moveY(begin: 16, end: 0, curve: AppMotion.emphasized),
        ],
      ),
    );
  }
}

class _CreateFab extends StatelessWidget {
  final bool extended;
  final VoidCallback onPressed;

  const _CreateFab({required this.extended, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Create agent',
      child: Pressable(
        onTap: onPressed,
        pressedScale: 0.92,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.emphasized,
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: extended ? 20 : 16),
          decoration: BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.brand.withValues(alpha: 0.45),
                blurRadius: 28,
                spreadRadius: -6,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              AnimatedSize(
                duration: AppMotion.base,
                curve: AppMotion.emphasized,
                child: extended
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text('New agent', style: AppText.title3.copyWith(color: Colors.white, fontSize: 15)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
