import 'package:agent_lab/common/widgets/ui/agent_avatar.dart';
import 'package:agent_lab/common/widgets/ui/composer.dart';
import 'package:agent_lab/common/widgets/ui/primitives.dart';
import 'package:agent_lab/models/create_agent_chat_message.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/providers/states/main_state.dart';
import 'package:agent_lab/screens/widgets/agent_actions.dart';
import 'package:agent_lab/utils/constants/app_enums.dart';
import 'package:agent_lab/utils/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _stepLabels = ['Describe', 'Model', 'Questions', 'Tools', 'Build'];

int _stepIndex(AgentCreationStep step) => switch (step) {
      AgentCreationStep.idle => 0,
      AgentCreationStep.streaming || AgentCreationStep.modelSelection || AgentCreationStep.pickingModel => 1,
      AgentCreationStep.answering => 2,
      AgentCreationStep.toolSelection => 3,
      AgentCreationStep.creating => 4,
      AgentCreationStep.done => 5,
      AgentCreationStep.error => -1,
    };

class CreateAgentScreen extends ConsumerStatefulWidget {
  const CreateAgentScreen({super.key});

  @override
  ConsumerState<CreateAgentScreen> createState() => _CreateAgentScreenState();
}

class _CreateAgentScreenState extends ConsumerState<CreateAgentScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Set<String> _selectedTools = {};
  int? _selectedModel;
  int _lastStep = 0;
  bool _addingToChat = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainProviderStateProvider.notifier).resetCreationFlow();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppMotion.slow,
          curve: AppMotion.emphasized,
        );
      }
    });
  }

  void _submitDescription() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    FocusScope.of(context).unfocus();
    ref.read(mainProviderStateProvider.notifier).startFetchChatStream(description: text);
  }

  void _submitAnswer([String? preset]) {
    final text = (preset ?? _textController.text).trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(mainProviderStateProvider.notifier).submitAnswer(answer: text);
  }

  void _useTemplate(String prompt) {
    _textController.text = prompt;
    _textController.selection = TextSelection.collapsed(offset: prompt.length);
    _focusNode.requestFocus();
  }

  void _startOver() {
    _selectedModel = null;
    _selectedTools.clear();
    ref.read(mainProviderStateProvider.notifier).resetCreationFlow();
  }

  Future<void> _addToChatAndOpen(String name) async {
    setState(() => _addingToChat = true);
    await ref.read(mainProviderStateProvider.notifier).addAgentToChat(agentName: name);
    if (!mounted) return;
    setState(() => _addingToChat = false);
    AgentActions.openChat(ref, context);
  }

  Future<bool> _confirmLeave() async {
    final step = ref.read(mainProviderStateProvider).creationStep;
    final inProgress = step != AgentCreationStep.idle && step != AgentCreationStep.done && step != AgentCreationStep.error;
    if (!inProgress) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard this agent?'),
        content: const Text('Your progress on this agent will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep building')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return leave == true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainProviderStateProvider);

    ref.listen(
      mainProviderStateProvider.select((s) => s.agentChatMessages.length),
      (prev, next) {
        if ((prev ?? 0) < next) _scrollToBottom();
      },
    );

    ref.listen(
      mainProviderStateProvider.select((s) => s.creationStep),
      (prev, next) {
        final idx = _stepIndex(next);
        if (idx >= 0) _lastStep = idx;
        if (next == AgentCreationStep.toolSelection) _selectedTools.clear();
        if (next == AgentCreationStep.modelSelection) _selectedModel = null;
        if (next == AgentCreationStep.done) HapticFeedback.heavyImpact();
        if (next == AgentCreationStep.answering) _focusNode.requestFocus();
        _scrollToBottom();
      },
    );

    final step = state.creationStep;
    final isError = step == AgentCreationStep.error;
    final current = isError ? _lastStep : _stepIndex(step);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleIconButton(
              icon: Icons.close_rounded,
              tooltip: 'Close',
              size: 36,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          title: const Text('New agent'),
          actions: [
            if (step != AgentCreationStep.idle && step != AgentCreationStep.done)
              TextButton(onPressed: _startOver, child: const Text('Start over')),
            const SizedBox(width: AppSpace.xs),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: _StepTracker(current: current, error: isError),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: state.agentChatMessages.isEmpty
                  ? _Intro(onTemplate: _useTemplate)
                  : _Conversation(
                      controller: _scrollController,
                      messages: state.agentChatMessages,
                      streaming: step == AgentCreationStep.streaming,
                    ),
            ),
            AnimatedSwitcher(
              duration: AppMotion.slow,
              switchInCurve: AppMotion.emphasized,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SizeTransition(sizeFactor: anim, axisAlignment: -1, child: child),
              ),
              child: KeyedSubtree(
                key: ValueKey(step),
                child: _buildBottom(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottom(MainState state) {
    switch (state.creationStep) {
      case AgentCreationStep.idle:
        return _Dock(
          child: Composer(
            controller: _textController,
            focusNode: _focusNode,
            hintText: 'Describe what your agent should do…',
            onSend: _submitDescription,
          ),
        );
      case AgentCreationStep.streaming:
        return _Dock(
          child: _WorkingBar(
            label: 'Scouting the best models for this job',
            trailing: TextButton(onPressed: _startOver, child: const Text('Cancel')),
          ),
        );
      case AgentCreationStep.modelSelection:
        return _buildModelPicker(state);
      case AgentCreationStep.pickingModel:
        return const _Dock(child: _WorkingBar(label: 'Preparing your model'));
      case AgentCreationStep.answering:
        return _buildAnswerInput(state);
      case AgentCreationStep.toolSelection:
        return _buildToolPicker(state);
      case AgentCreationStep.creating:
        return const _Dock(child: _WorkingBar(label: 'Writing and testing your agent', building: true));
      case AgentCreationStep.done:
        return _buildDone(state);
      case AgentCreationStep.error:
        return _buildError(state);
    }
  }

  // ─── Model picker ────────────────────────────────────────────────────────

  Widget _buildModelPicker(MainState state) {
    final models = state.availableModels.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    final maxH = MediaQuery.sizeOf(context).height * 0.42;

    if (models.isEmpty) {
      return _Dock(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No suitable models found', style: AppText.title3),
            const SizedBox(height: 4),
            const Text('Try describing the task in a different way.', style: AppText.bodySecondary),
            const SizedBox(height: AppSpace.md),
            GradientButton(label: 'Rephrase', icon: Icons.edit_rounded, onPressed: _startOver),
          ],
        ),
      );
    }

    final selected = _selectedModel != null && _selectedModel! < models.length ? models[_selectedModel!] : null;

    return _Dock(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Choose a model', style: AppText.title3),
              const SizedBox(width: AppSpace.xs),
              Tag(label: '${models.length} found', color: AppColors.brand),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: models.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpace.xs),
              itemBuilder: (context, i) => _ModelCard(
                data: models[i],
                best: i == 0,
                selected: _selectedModel == i,
                onTap: () => setState(() => _selectedModel = i),
              ).animate().fadeIn(delay: (50 * i).ms, duration: AppMotion.base).moveX(begin: 12, end: 0),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          GradientButton(
            label: selected == null ? 'Select a model to continue' : 'Use ${selected['name'] ?? 'this model'}',
            icon: selected == null ? null : Icons.arrow_forward_rounded,
            onPressed: selected == null
                ? null
                : () {
                    final name = (selected['name'] as String?) ?? 'Unknown';
                    final index = (selected['index'] as num?) ?? _selectedModel!;
                    ref.read(mainProviderStateProvider.notifier).pickModel(modelChoice: index.toInt(), modelName: name);
                  },
          ),
        ],
      ),
    );
  }

  // ─── Questions ───────────────────────────────────────────────────────────

  Widget _buildAnswerInput(MainState state) {
    final questions = state.pickAModelResult?.clarifying_questions ?? [];
    final total = questions.length;
    final current = state.currentQuestionIndex;

    return _Dock(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Question ${current + 1} of $total', style: AppText.caption.copyWith(color: AppColors.text)),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Row(
                  children: [
                    for (var i = 0; i < total; i++)
                      Expanded(
                        child: AnimatedContainer(
                          duration: AppMotion.base,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            gradient: i <= current ? AppGradients.brand : null,
                            color: i <= current ? null : AppColors.surface3,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.xs),
              TextButton(
                onPressed: () => _submitAnswer('No preference'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Skip'),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Composer(
            controller: _textController,
            focusNode: _focusNode,
            hintText: 'Type your answer…',
            onSend: _submitAnswer,
          ),
        ],
      ),
    );
  }

  // ─── Tools ───────────────────────────────────────────────────────────────

  Widget _buildToolPicker(MainState state) {
    final tools = state.pickAModelResult?.suggested_tools ?? [];
    final maxH = MediaQuery.sizeOf(context).height * 0.36;
    final allSelected = tools.isNotEmpty && tools.every((t) => _selectedTools.contains(t.name ?? ''));

    return _Dock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Give it tools', style: AppText.title3),
              const SizedBox(width: 6),
              Text('optional', style: AppText.caption.copyWith(color: AppColors.textTertiary)),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                onPressed: () => setState(() {
                  if (allSelected) {
                    _selectedTools.clear();
                  } else {
                    _selectedTools.addAll(tools.map((t) => t.name ?? '').where((n) => n.isNotEmpty));
                  }
                }),
                child: Text(allSelected ? 'Clear' : 'Select all'),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: tools.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpace.xs),
              itemBuilder: (context, i) {
                final tool = tools[i];
                final name = tool.name ?? '';
                final isSelected = _selectedTools.contains(name);
                return Pressable(
                  pressedScale: 0.985,
                  onTap: () => setState(() => isSelected ? _selectedTools.remove(name) : _selectedTools.add(name)),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    padding: const EdgeInsets.all(AppSpace.sm),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.brandSoft : AppColors.surface2,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: isSelected ? AppColors.brand : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: AppMotion.fast,
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppGradients.brand : null,
                            borderRadius: BorderRadius.circular(7),
                            border: isSelected ? null : Border.all(color: AppColors.borderStrong, width: 1.5),
                          ),
                          child: isSelected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppText.label),
                              if ((tool.description ?? '').isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(tool.description!, style: AppText.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpace.md),
          GradientButton(
            icon: Icons.rocket_launch_rounded,
            label: _selectedTools.isEmpty
                ? 'Build without tools'
                : 'Build with ${_selectedTools.length} tool${_selectedTools.length == 1 ? '' : 's'}',
            onPressed: () => ref
                .read(mainProviderStateProvider.notifier)
                .confirmToolSelection(toolChoices: _selectedTools.toList()),
          ),
        ],
      ),
    );
  }

  // ─── Done / error ────────────────────────────────────────────────────────

  Widget _buildDone(MainState state) {
    final name = state.createdAgent?.name ?? 'Your agent';
    return _Dock(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AgentAvatar.paletteFor(name).last.withValues(alpha: 0.35), Colors.transparent],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.85, end: 1.1, duration: 1600.ms),
              AgentAvatar(name: name, size: 72, glow: true)
                  .animate()
                  .scaleXY(begin: 0.4, end: 1, duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 200.ms),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text('$name is ready', style: AppText.title2, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text(
            'Add it to the chat to start using it right away.',
            style: AppText.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.lg),
          GradientButton(
            label: 'Add to chat & start',
            icon: Icons.forum_rounded,
            loading: _addingToChat,
            onPressed: state.createdAgent?.name == null ? null : () => _addToChatAndOpen(state.createdAgent!.name!),
          ),
          const SizedBox(height: AppSpace.xs),
          GhostButton(label: 'Back to agents', onPressed: () => Navigator.of(context).pop()),
        ],
      ).animate().fadeIn(duration: AppMotion.slow).moveY(begin: 20, end: 0, curve: AppMotion.emphasized),
    );
  }

  Widget _buildError(MainState state) {
    return _Dock(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Surface(
            color: AppColors.dangerSoft,
            borderColor: AppColors.danger.withValues(alpha: 0.3),
            radius: AppRadius.md,
            padding: const EdgeInsets.all(AppSpace.sm + 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('That didn\'t work', style: AppText.label.copyWith(color: AppColors.danger)),
                      const SizedBox(height: 2),
                      Text(
                        (state.creationError ?? '').isEmpty ? 'Something went wrong. Please try again.' : state.creationError!,
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          GradientButton(label: 'Start over', icon: Icons.refresh_rounded, onPressed: _startOver),
        ],
      ),
    );
  }
}

// ─── Step tracker ────────────────────────────────────────────────────────────

class _StepTracker extends StatelessWidget {
  final int current;
  final bool error;
  const _StepTracker({required this.current, required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, AppSpace.sm),
      child: Row(
        children: [
          for (var i = 0; i < _stepLabels.length; i++)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.slow,
                    curve: AppMotion.emphasized,
                    height: 4,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i == current && error
                          ? AppColors.danger
                          : i < current
                              ? AppColors.brand
                              : i == current
                                  ? null
                                  : AppColors.surface3,
                      gradient: i == current && !error ? AppGradients.brand : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedDefaultTextStyle(
                    duration: AppMotion.base,
                    style: AppText.caption.copyWith(
                      fontSize: 11,
                      color: i == current
                          ? (error ? AppColors.danger : AppColors.text)
                          : i < current
                              ? AppColors.textSecondary
                              : AppColors.textTertiary,
                    ),
                    child: Text(_stepLabels[i], maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Intro (idle) ────────────────────────────────────────────────────────────

class _Intro extends StatelessWidget {
  final ValueChanged<String> onTemplate;
  const _Intro({required this.onTemplate});

  static const _templates = [
    (Icons.picture_as_pdf_rounded, 'PDF summarizer', 'Summarize long PDF documents into concise bullet points with key takeaways.'),
    (Icons.graphic_eq_rounded, 'Audio transcriber', 'Transcribe audio recordings into clean, punctuated text.'),
    (Icons.image_search_rounded, 'Image describer', 'Describe the contents of images in detail for accessibility.'),
    (Icons.sentiment_satisfied_alt_rounded, 'Review analyst', 'Classify customer reviews as positive, negative or neutral and explain why.'),
    (Icons.translate_rounded, 'Translator', 'Translate text between English and Arabic while keeping a formal tone.'),
    (Icons.code_rounded, 'Code explainer', 'Explain what a code snippet does in simple, beginner-friendly terms.'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.lg, AppSpace.gutter, AppSpace.lg),
      children: [
        const Text('What should your\nagent do?', style: AppText.display),
        const SizedBox(height: AppSpace.xs),
        const Text(
          'Describe the job in plain words. Be specific about the input it gets and the output you want.',
          style: AppText.bodySecondary,
        ),
        const SizedBox(height: AppSpace.xl),
        const SectionLabel('Start from an idea'),
        for (final (i, t) in _templates.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.xs),
            child: Pressable(
              pressedScale: 0.985,
              onTap: () => onTemplate(t.$3),
              child: Surface(
                padding: const EdgeInsets.all(AppSpace.sm),
                radius: AppRadius.md,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AgentAvatar.paletteFor(t.$2).map((c) => c.withValues(alpha: 0.2)).toList(),
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(t.$1, size: 20, color: AgentAvatar.paletteFor(t.$2).first),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.$2, style: AppText.label),
                          const SizedBox(height: 2),
                          Text(t.$3, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const Icon(Icons.north_west_rounded, size: 16, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (40 * i).ms, duration: AppMotion.slow).moveY(begin: 10, end: 0),
          ),
      ],
    );
  }
}

// ─── Conversation ────────────────────────────────────────────────────────────

/// Groups consecutive streamed status events into a single live activity card,
/// so the user sees *one* evolving progress log instead of a wall of bubbles.
class _Conversation extends StatelessWidget {
  final ScrollController controller;
  final List<CreateAgentChatMessage> messages;
  final bool streaming;

  const _Conversation({required this.controller, required this.messages, required this.streaming});

  @override
  Widget build(BuildContext context) {
    final blocks = <Object>[];
    for (final m in messages) {
      if (m.isActivity) {
        if (blocks.isNotEmpty && blocks.last is List<CreateAgentChatMessage>) {
          (blocks.last as List<CreateAgentChatMessage>).add(m);
        } else {
          blocks.add(<CreateAgentChatMessage>[m]);
        }
      } else {
        blocks.add(m);
      }
    }

    return ListView.builder(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, AppSpace.md, AppSpace.md),
      itemCount: blocks.length,
      itemBuilder: (context, i) {
        final block = blocks[i];
        final Widget child;
        if (block is List<CreateAgentChatMessage>) {
          child = _ActivityCard(events: block, live: streaming && i == blocks.length - 1);
        } else {
          final m = block as CreateAgentChatMessage;
          child = m.isUser ? _UserBubble(text: m.content) : _LabMessage(text: m.content);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.md),
          child: child.animate().fadeIn(duration: AppMotion.base).moveY(begin: 10, end: 0, curve: AppMotion.emphasized),
        );
      },
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          gradient: AppGradients.userBubble,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          ),
        ),
        child: Text(text, style: AppText.body.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _LabMessage extends StatelessWidget {
  final String text;
  const _LabMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LabMark(size: 28),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(text, style: AppText.body),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final List<CreateAgentChatMessage> events;
  final bool live;

  const _ActivityCard({required this.events, required this.live});

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: const EdgeInsets.all(AppSpace.md),
      radius: AppRadius.lg,
      borderColor: live ? AppColors.brand.withValues(alpha: 0.35) : AppColors.border,
      gradient: live
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.brand.withValues(alpha: 0.08), AppColors.surface1],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (live)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              else
                const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
              const SizedBox(width: AppSpace.xs),
              Expanded(
                child: Text(
                  live ? 'Working on it' : 'Research complete',
                  style: AppText.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${events.length} step${events.length == 1 ? '' : 's'}', style: AppText.caption),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          for (var i = 0; i < events.length; i++)
            _ActivityLine(
              text: events[i].content,
              isCurrent: live && i == events.length - 1,
              isProgress: events[i].isProgress,
              isLast: i == events.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ActivityLine extends StatelessWidget {
  final String text;
  final bool isCurrent;
  final bool isProgress;
  final bool isLast;

  const _ActivityLine({required this.text, required this.isCurrent, required this.isProgress, required this.isLast});

  @override
  Widget build(BuildContext context) {
    Widget marker = Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrent ? AppColors.brand : AppColors.success.withValues(alpha: 0.8),
      ),
    );
    if (isCurrent) {
      marker = marker
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 0.8, end: 1.4, duration: 700.ms)
          .fade(begin: 0.5, end: 1);
    }

    Widget label = Text(
      text,
      style: AppText.caption.copyWith(
        color: isCurrent ? AppColors.text : AppColors.textSecondary,
        fontStyle: isProgress ? FontStyle.italic : FontStyle.normal,
      ),
    );
    if (isCurrent) {
      label = label.animate(onPlay: (c) => c.repeat()).shimmer(duration: 1600.ms, color: AppColors.brand);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                marker,
                if (!isLast)
                  Expanded(
                    child: Container(width: 1.5, margin: const EdgeInsets.symmetric(vertical: 3), color: AppColors.border),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.sm),
              child: label,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom dock pieces ──────────────────────────────────────────────────────

class _Dock extends StatelessWidget {
  final Widget child;
  const _Dock({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        border: Border(top: BorderSide(color: AppColors.borderStrong)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, AppSpace.md, AppSpace.sm),
          child: child,
        ),
      ),
    );
  }
}

class _WorkingBar extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final bool building;

  const _WorkingBar({required this.label, this.trailing, this.building = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(building ? Icons.construction_rounded : Icons.travel_explore_rounded, size: 18, color: AppColors.brand)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(begin: -0.03, end: 0.03, duration: 600.ms),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(label, style: AppText.label)
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1800.ms, color: AppColors.brand),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        const ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          child: LinearProgressIndicator(minHeight: 3),
        ),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool best;
  final bool selected;
  final VoidCallback onTap;

  const _ModelCard({required this.data, required this.best, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = (data['name'] as String?) ?? 'Unknown';
    final provider = (data['provider'] as String?) ?? '';
    final license = data['license'] as String?;
    final gated = data['gated'] == true;
    final method = data['method'] as String?;

    return Semantics(
      selected: selected,
      button: true,
      label: '$name by $provider${best ? ', best match' : ''}',
      child: Pressable(
        pressedScale: 0.985,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.all(AppSpace.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.brandSoft : AppColors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: selected ? AppColors.brand : AppColors.border, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.hub_rounded, size: 20, color: AppColors.brand),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (best) const Tag(label: 'Best match', icon: Icons.star_rounded, color: AppColors.warning),
                        if (provider.isNotEmpty) Tag(label: provider),
                        if ((method ?? '').isNotEmpty) Tag(label: method!, color: AppColors.info),
                        if ((license ?? '').isNotEmpty) Tag(label: license!),
                        if (gated) const Tag(label: 'Gated', icon: Icons.lock_rounded, color: AppColors.danger),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.xs),
              AnimatedContainer(
                duration: AppMotion.fast,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected ? AppGradients.brand : null,
                  border: selected ? null : Border.all(color: AppColors.borderStrong, width: 1.5),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
