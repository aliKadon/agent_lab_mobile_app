import 'package:agent_lab/common/widgets/conditional_marquee_text.dart';
import 'package:agent_lab/models/create_agent_chat_message.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/providers/states/main_state.dart';
import 'package:agent_lab/utils/constants/app_enums.dart';
import 'package:agent_lab/utils/constants/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateAgentScreen extends ConsumerStatefulWidget {
  const CreateAgentScreen({super.key});

  @override
  ConsumerState<CreateAgentScreen> createState() => _CreateAgentScreenState();
}

class _CreateAgentScreenState extends ConsumerState<CreateAgentScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final Set<String> _selectedTools = {};

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
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainProviderStateProvider);
    final notifier = ref.read(mainProviderStateProvider.notifier);

    ref.listen(
      mainProviderStateProvider.select((s) => s.agentChatMessages.length),
      (prev, next) {
        if ((prev ?? 0) < next) _scrollToBottom();
      },
    );

    ref.listen(
      mainProviderStateProvider.select((s) => s.creationStep),
      (prev, next) {
        if (next == AgentCreationStep.toolSelection) {
          _selectedTools.clear();
        }
      },
    );

    return Scaffold(
      backgroundColor: Pallete.darkBg,
      appBar: AppBar(
        backgroundColor: Pallete.darkBg,
        elevation: 0,
        title: const Text(
          'Create Agent',
          style: TextStyle(color: Pallete.white, fontWeight: FontWeight.w600, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Pallete.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.agentChatMessages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: state.agentChatMessages.length,
                    itemBuilder: (context, index) {
                      return _ChatBubble(message: state.agentChatMessages[index]);
                    },
                  ),
          ),
          _buildBottomSection(state, notifier),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Pallete.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_outlined, size: 48, color: Pallete.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Describe the agent you want\nto create',
            style: TextStyle(color: Pallete.grey, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(MainState state, MainProvider notifier) {
    switch (state.creationStep) {
      case AgentCreationStep.idle:
        return _buildDescriptionInput(notifier);
      case AgentCreationStep.streaming:
        return _buildStatusBar(label: 'Searching for models...', showSpinner: true);
      case AgentCreationStep.modelSelection:
        return _buildModelSelection(state, notifier);
      case AgentCreationStep.pickingModel:
        return _buildStatusBar(label: 'Selecting model...', showSpinner: true);
      case AgentCreationStep.answering:
        return _buildAnswerInput(state, notifier);
      case AgentCreationStep.toolSelection:
        return _buildToolSelection(state, notifier);
      case AgentCreationStep.creating:
        return _buildStatusBar(label: 'Creating your agent...', showSpinner: true);
      case AgentCreationStep.done:
        return _buildDoneSection(state);
      case AgentCreationStep.error:
        return _buildErrorSection(state, notifier);
    }
  }

  Widget _buildDescriptionInput(MainProvider notifier) {
    return _BottomContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Pallete.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Describe your agent...',
                hintStyle: TextStyle(color: Pallete.grey.withValues(alpha: 0.6), fontSize: 14),
                filled: true,
                fillColor: Pallete.grey20,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _submitDescription(notifier),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Pallete.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Pallete.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _submitDescription(MainProvider notifier) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    notifier.startFetchChatStream(description: text);
  }

  Widget _buildStatusBar({required String label, bool showSpinner = false}) {
    return _BottomContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSpinner)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Pallete.primary),
            ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Pallete.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildModelSelection(MainState state, MainProvider notifier) {
    final models = state.availableModels;
    return _BottomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select a model',
            style: TextStyle(color: Pallete.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: models.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final model = models[i] as Map<String, dynamic>;
                final name = (model['name'] as String?) ?? 'Unknown';
                final provider = (model['provider'] as String?) ?? '';
                final index = (model['index'] as num?) ?? i;
                return _ModelCard(
                  name: name,
                  provider: provider,
                  onTap: () => notifier.pickModel(
                    modelChoice: index.toInt(),
                    modelName: name,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(MainState state, MainProvider notifier) {
    final questions = state.pickAModelResult?.clarifying_questions ?? [];
    final total = questions.length;
    final current = state.currentQuestionIndex + 1;

    return _BottomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Question $current of $total',
                style: const TextStyle(color: Pallete.grey, fontSize: 11),
              ),
              const Spacer(),
              SizedBox(
                width: 80,
                height: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: current / total,
                    backgroundColor: Pallete.grey20,
                    valueColor: const AlwaysStoppedAnimation<Color>(Pallete.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Pallete.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type your answer...',
                    hintStyle: TextStyle(color: Pallete.grey.withValues(alpha: 0.6), fontSize: 14),
                    filled: true,
                    fillColor: Pallete.grey20,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _submitAnswer(notifier),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Pallete.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Pallete.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitAnswer(MainProvider notifier) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    notifier.submitAnswer(answer: text);
  }

  Widget _buildToolSelection(MainState state, MainProvider notifier) {
    final tools = state.pickAModelResult?.suggested_tools ?? [];

    return _BottomContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Select tools',
                style: TextStyle(color: Pallete.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                '(optional)',
                style: TextStyle(color: Pallete.grey.withValues(alpha: 0.7), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: StatefulBuilder(
              builder: (context, setInnerState) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: tools.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final tool = tools[i];
                    final name = tool.name ?? '';
                    final isSelected = _selectedTools.contains(name);
                    return GestureDetector(
                      onTap: () {
                        setInnerState(() {
                          if (isSelected) {
                            _selectedTools.remove(name);
                          } else {
                            _selectedTools.add(name);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Pallete.primary.withValues(alpha: 0.15)
                              : Pallete.grey20,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? Pallete.primary : const Color(0xFF2D2D2D),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              size: 18,
                              color: isSelected ? Pallete.primary : Pallete.grey,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: isSelected ? Pallete.white : const Color(0xFFD4D4D4),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (tool.description != null && tool.description!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      tool.description!,
                                      style: TextStyle(
                                        color: Pallete.grey.withValues(alpha: 0.7),
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => notifier.confirmToolSelection(
                toolChoices: _selectedTools.toList(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _selectedTools.isEmpty ? 'Continue without tools' : 'Continue with ${_selectedTools.length} tool${_selectedTools.length == 1 ? '' : 's'}',
                style: const TextStyle(color: Pallete.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneSection(MainState state) {
    return _BottomContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.createdAgent?.name != null
                      ? '"${state.createdAgent!.name}" is ready to use!'
                      : 'Agent created successfully!',
                  style: const TextStyle(color: Pallete.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'View Agents',
                style: TextStyle(color: Pallete.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(MainState state, MainProvider notifier) {
    return _BottomContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.creationError ?? 'Something went wrong. Please try again.',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => notifier.resetCreationFlow(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Pallete.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(color: Pallete.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomContainer extends StatelessWidget {
  final Widget child;

  const _BottomContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(top: BorderSide(color: Color(0xFF242424))),
      ),
      child: child,
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final CreateAgentChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? Pallete.primary : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
          border: message.isUser ? null : Border.all(color: const Color(0xFF2D2D2D)),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser ? Pallete.white : const Color(0xFFD4D4D4),
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String name;
  final String provider;
  final VoidCallback onTap;

  const _ModelCard({required this.name, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 148.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Pallete.grey20,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: Pallete.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Pallete.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.memory_rounded, size: 14, color: Pallete.primary),
            ),
            const SizedBox(height: 6),
            ConditionalMarqueeText(
              width: 120.w,
               text: name,
              style: const TextStyle(color: Pallete.white, fontSize: 12, fontWeight: FontWeight.w600),
              noOfRounds: 1,
            ),
            const SizedBox(height: 2),
            Text(
              provider,
              style: TextStyle(color: Pallete.grey.withValues(alpha: 0.7), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}