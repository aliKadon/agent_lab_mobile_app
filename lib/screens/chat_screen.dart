import 'dart:io';

import 'package:agent_lab/common/widgets/ui/agent_avatar.dart';
import 'package:agent_lab/common/widgets/ui/app_snack.dart';
import 'package:agent_lab/common/widgets/ui/composer.dart';
import 'package:agent_lab/common/widgets/ui/primitives.dart';
import 'package:agent_lab/models/all_agents_list_model.dart';
import 'package:agent_lab/models/chat_message_model.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/screens/create_agent_screen.dart';
import 'package:agent_lab/utils/constants/app_enums.dart';
import 'package:agent_lab/utils/theme/app_tokens.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chewie/chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  File? _pendingFile;
  String? _pendingFileName;
  ChatAttachmentType? _pendingType;
  bool _isUploading = false;
  bool _showJumpButton = false;

  /// Messages at or beyond this index animate in; older ones render statically
  /// so scrolling back through history doesn't replay entrance animations.
  int _animateFrom = 1 << 30;

  @override
  void initState() {
    super.initState();
    _animateFrom = ref.read(mainProviderStateProvider).chatMessages.length;
    _scrollController.addListener(() {
      final show = _scrollController.hasClients && _scrollController.offset > 320;
      if (show != _showJumpButton) setState(() => _showJumpButton = show);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToLatest() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(0, duration: AppMotion.slow, curve: AppMotion.emphasized);
  }

  // ─── Attachments ────────────────────────────────────────────────────────

  Future<void> _pick(ChatAttachmentType type, {bool camera = false}) async {
    Navigator.pop(context);
    File? picked;
    String? name;

    try {
      if (type == ChatAttachmentType.image) {
        final img = await ImagePicker().pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);
        if (img == null) return;
        picked = File(img.path);
        name = img.name;
      } else if (type == ChatAttachmentType.audio) {
        final result = await FilePicker.platform.pickFiles(type: FileType.audio);
        if (result == null || result.files.isEmpty || result.files.first.path == null) return;
        picked = File(result.files.first.path!);
        name = result.files.first.name;
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx', 'csv'],
        );
        if (result == null || result.files.isEmpty || result.files.first.path == null) return;
        picked = File(result.files.first.path!);
        name = result.files.first.name;
      }
    } catch (_) {
      showAppSnack('Couldn\'t open that file. Check app permissions.', tone: SnackTone.error);
      return;
    }
    if (!mounted) return;

    setState(() {
      _isUploading = true;
      _pendingFile = picked;
      _pendingFileName = name;
      _pendingType = type;
    });

    await ref.read(mainProviderStateProvider.notifier).uploadChatAttachment(
          file: picked,
          onResult: (success) {
            if (!mounted) return;
            setState(() {
              _isUploading = false;
              if (!success) _clearPending();
            });
          },
        );
  }

  void _clearPending() {
    _pendingFile = null;
    _pendingFileName = null;
    _pendingType = null;
  }

  void _showAttachmentSheet() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.md, 0, AppSpace.md, AppSpace.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add to message', style: AppText.title3),
              const SizedBox(height: AppSpace.md),
              Row(
                children: [
                  _AttachOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Photos',
                    color: AppColors.info,
                    onTap: () => _pick(ChatAttachmentType.image),
                  ),
                  _AttachOption(
                    icon: Icons.photo_camera_rounded,
                    label: 'Camera',
                    color: AppColors.success,
                    onTap: () => _pick(ChatAttachmentType.image, camera: true),
                  ),
                  _AttachOption(
                    icon: Icons.description_rounded,
                    label: 'Document',
                    color: AppColors.warning,
                    onTap: () => _pick(ChatAttachmentType.document),
                  ),
                  _AttachOption(
                    icon: Icons.graphic_eq_rounded,
                    label: 'Audio',
                    color: AppColors.magenta,
                    onTap: () => _pick(ChatAttachmentType.audio),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sending ───────────────────────────────────────────────────────────

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _textController.text).trim();
    if (text.isEmpty && _pendingFileName == null) return;
    if (_isUploading || ref.read(mainProviderStateProvider).isSendingMessage) return;

    final attachmentName = _pendingFileName;
    final attachmentType = _pendingType;
    final localPath = _pendingFile?.path;

    _textController.clear();
    setState(_clearPending);
    _jumpToLatest();

    await ref.read(mainProviderStateProvider.notifier).sendChatMessage(
          message: text,
          attachmentName: attachmentName,
          attachmentType: attachmentType,
          localPath: localPath,
        );
  }

  void _newChat() {
    final notifier = ref.read(mainProviderStateProvider.notifier);
    final previous = List<ChatMessageModel>.from(ref.read(mainProviderStateProvider).chatMessages);
    if (previous.isEmpty) return;
    notifier.clearChat();
    setState(() => _animateFrom = 0);
    showAppSnack(
      'Started a new chat',
      action: SnackBarAction(
        label: 'Undo',
        textColor: AppColors.brand,
        onPressed: () {
          setState(() => _animateFrom = previous.length);
          notifier.restoreChat(previous);
        },
      ),
    );
  }

  void _openParticipants() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ParticipantsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainProviderStateProvider);
    final messages = state.chatMessages;
    final isSending = state.isSendingMessage;
    final agents = state.allAgentsList?.agents ?? const <AgentModel>[];
    final activeNames = agents.where((a) => a.active == true).map((a) => a.name ?? '?').toList();

    return Scaffold(
      appBar: _ChatAppBar(
        activeNames: activeNames,
        hasMessages: messages.isNotEmpty,
        busy: isSending,
        onParticipants: _openParticipants,
        onNewChat: _newChat,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                messages.isEmpty
                    ? _EmptyChat(
                        activeNames: activeNames,
                        onSuggestion: _send,
                        onChooseAgents: _openParticipants,
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.md, AppSpace.md, AppSpace.xs),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final index = messages.length - 1 - i;
                          final msg = messages[index];
                          final prevIsUser = index > 0 ? messages[index - 1].isUser : null;
                          Widget child = _MessageRow(
                            message: msg,
                            isLatest: i == 0,
                            groupedWithPrevious: prevIsUser == msg.isUser,
                            onRetry: () => ref.read(mainProviderStateProvider.notifier).retryLastMessage(),
                          );
                          if (index >= _animateFrom) {
                            child = child
                                .animate()
                                .fadeIn(duration: AppMotion.base)
                                .moveY(begin: 12, end: 0, curve: AppMotion.emphasized);
                          }
                          return child;
                        },
                      ),
                Positioned(
                  right: AppSpace.md,
                  bottom: AppSpace.sm,
                  child: AnimatedScale(
                    scale: _showJumpButton ? 1 : 0,
                    duration: AppMotion.base,
                    curve: AppMotion.emphasized,
                    child: CircleIconButton(
                      icon: Icons.arrow_downward_rounded,
                      tooltip: 'Jump to latest',
                      background: AppColors.surface3,
                      onPressed: _jumpToLatest,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.sm, AppSpace.xs, AppSpace.sm, AppSpace.sm),
              child: Composer(
                controller: _textController,
                hintText: activeNames.isEmpty ? 'Message the lab…' : 'Message ${activeNames.length == 1 ? activeNames.first : 'your agents'}…',
                busy: isSending,
                onSend: _send,
                onAttach: _showAttachmentSheet,
                canSendEmpty: _pendingFileName != null && !_isUploading,
                enabled: !_isUploading,
                header: _pendingFileName == null
                    ? null
                    : _PendingAttachment(
                        file: _pendingFile,
                        name: _pendingFileName!,
                        type: _pendingType,
                        uploading: _isUploading,
                        onClear: () {
                          ref.read(mainProviderStateProvider.notifier).clearPendingAttachment();
                          setState(_clearPending);
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── App bar ─────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> activeNames;
  final bool hasMessages;
  final bool busy;
  final VoidCallback onParticipants;
  final VoidCallback onNewChat;

  const _ChatAppBar({
    required this.activeNames,
    required this.hasMessages,
    required this.busy,
    required this.onParticipants,
    required this.onNewChat,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final count = activeNames.length;
    return AppBar(
      toolbarHeight: 64,
      titleSpacing: AppSpace.md,
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
      title: Semantics(
        button: true,
        label: 'Manage agents in chat',
        child: Pressable(
          onTap: onParticipants,
          pressedScale: 0.98,
          child: Row(
            children: [
              const LabMark(size: 36),
              const SizedBox(width: AppSpace.sm),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Chat', style: AppText.title3),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: AppMotion.base,
                      child: Row(
                        key: ValueKey('$busy-$count'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (busy) ...[
                            const TypingDots(color: AppColors.brand),
                            const SizedBox(width: 6),
                            Text('Thinking', style: AppText.caption.copyWith(color: AppColors.brand)),
                          ] else if (count > 0) ...[
                            AvatarStack(names: activeNames, size: 16, max: 3),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '$count agent${count == 1 ? '' : 's'} listening',
                                style: AppText.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.expand_more_rounded, size: 16, color: AppColors.textTertiary),
                          ] else ...[
                            Text('Tap to add agents', style: AppText.caption.copyWith(color: AppColors.warning)),
                            const Icon(Icons.expand_more_rounded, size: 16, color: AppColors.warning),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (hasMessages)
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.md),
            child: CircleIconButton(
              icon: Icons.edit_square,
              tooltip: 'New chat',
              size: 38,
              onPressed: busy ? null : onNewChat,
            ),
          ),
      ],
    );
  }
}

// ─── Participants sheet ──────────────────────────────────────────────────────

class _ParticipantsSheet extends ConsumerStatefulWidget {
  const _ParticipantsSheet();

  @override
  ConsumerState<_ParticipantsSheet> createState() => _ParticipantsSheetState();
}

class _ParticipantsSheetState extends ConsumerState<_ParticipantsSheet> {
  final Set<String> _busy = {};

  Future<void> _toggle(AgentModel agent) async {
    final name = agent.name;
    if (name == null || _busy.contains(name)) return;
    setState(() => _busy.add(name));
    final notifier = ref.read(mainProviderStateProvider.notifier);
    if (agent.active == true) {
      await notifier.removeAgentFromChat(agentName: name);
    } else {
      await notifier.addAgentToChat(agentName: name);
    }
    if (mounted) setState(() => _busy.remove(name));
  }

  @override
  Widget build(BuildContext context) {
    final agents = ref.watch(mainProviderStateProvider.select((s) => s.allAgentsList?.agents ?? const <AgentModel>[]));
    final sorted = [...agents]..sort((a, b) => (b.active == true ? 1 : 0) - (a.active == true ? 1 : 0));
    final activeCount = agents.where((a) => a.active == true).length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.gutter, 0, AppSpace.gutter, AppSpace.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Agents in this chat', style: AppText.title2),
                      const SizedBox(height: 4),
                      Text(
                        activeCount == 0
                            ? 'Turn agents on to let them answer your messages.'
                            : '$activeCount of ${agents.length} can answer your messages.',
                        style: AppText.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: agents.isEmpty
                ? EmptyState(
                    icon: Icons.smart_toy_outlined,
                    title: 'No agents yet',
                    message: 'Create an agent and it will show up here.',
                    action: GradientButton(
                      label: 'Create agent',
                      icon: Icons.auto_awesome_rounded,
                      expand: false,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateAgentScreen()));
                      },
                    ),
                  )
                : ListView.separated(
                    controller: scroll,
                    padding: EdgeInsets.fromLTRB(
                      AppSpace.md,
                      0,
                      AppSpace.md,
                      MediaQuery.paddingOf(context).bottom + AppSpace.md,
                    ),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpace.xs),
                    itemBuilder: (context, i) {
                      final a = sorted[i];
                      final name = a.name ?? 'Agent';
                      final active = a.active == true;
                      final busy = _busy.contains(name);
                      return Pressable(
                        pressedScale: 0.985,
                        onTap: () => _toggle(a),
                        child: AnimatedContainer(
                          duration: AppMotion.base,
                          padding: const EdgeInsets.all(AppSpace.sm),
                          decoration: BoxDecoration(
                            color: active ? AppColors.success.withValues(alpha: 0.06) : AppColors.surface2,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: active ? AppColors.success.withValues(alpha: 0.3) : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              AgentAvatar(name: name, size: 40, active: active),
                              const SizedBox(width: AppSpace.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: AppText.label.copyWith(fontSize: 14.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    if ((a.description ?? '').isNotEmpty)
                                      Text(
                                        a.description!,
                                        style: AppText.caption,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpace.xs),
                              busy
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                    )
                                  : Switch(
                                      value: active,
                                      activeTrackColor: AppColors.success,
                                      onChanged: (_) => _toggle(a),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyChat extends StatelessWidget {
  final List<String> activeNames;
  final ValueChanged<String> onSuggestion;
  final VoidCallback onChooseAgents;

  const _EmptyChat({required this.activeNames, required this.onSuggestion, required this.onChooseAgents});

  static const _suggestions = [
    (Icons.lightbulb_outline_rounded, 'What can you do?', 'What can you help me with?'),
    (Icons.summarize_outlined, 'Summarize', 'Summarize a document for me'),
    (Icons.insights_rounded, 'Analyze a file', 'Analyze this file and give me the key insights'),
    (Icons.translate_rounded, 'Translate', 'Translate this text into Spanish'),
  ];

  @override
  Widget build(BuildContext context) {
    if (activeNames.isEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: EmptyState(
            icon: Icons.group_add_rounded,
            title: 'Invite agents to the chat',
            message: 'Agents you add here can read your messages and files and answer you directly.',
            action: GradientButton(
              label: 'Choose agents',
              icon: Icons.add_rounded,
              expand: false,
              onPressed: onChooseAgents,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.xxl, AppSpace.gutter, AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LabMark(size: 52)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1, end: 1.06, duration: 1800.ms, curve: Curves.easeInOut),
          const SizedBox(height: AppSpace.lg),
          const Text('What can we do\nfor you today?', style: AppText.display),
          const SizedBox(height: AppSpace.sm),
          Pressable(
            onTap: onChooseAgents,
            child: Row(
              children: [
                AvatarStack(names: activeNames, size: 22),
                const SizedBox(width: AppSpace.xs),
                Flexible(
                  child: Text(
                    activeNames.length == 1
                        ? '${activeNames.first} is ready'
                        : '${activeNames.length} agents are ready',
                    style: AppText.bodySecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - AppSpace.xs) / 2;
              return Wrap(
                spacing: AppSpace.xs,
                runSpacing: AppSpace.xs,
                children: [
                  for (final (i, s) in _suggestions.indexed)
                    SizedBox(
                      width: w,
                      child: Pressable(
                        onTap: () => onSuggestion(s.$3),
                        child: Surface(
                          padding: const EdgeInsets.all(AppSpace.md),
                          radius: AppRadius.md,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(s.$1, size: 20, color: AppColors.brand),
                              const SizedBox(height: AppSpace.sm),
                              Text(s.$2, style: AppText.label),
                              const SizedBox(height: 2),
                              Text(s.$3, style: AppText.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (60 * i).ms, duration: AppMotion.slow).moveY(begin: 10, end: 0),
                    ),
                ],
              );
            },
          ),
        ],
      ).animate().fadeIn(duration: AppMotion.slow),
    );
  }
}

// ─── Messages ────────────────────────────────────────────────────────────────

class _MessageRow extends StatelessWidget {
  final ChatMessageModel message;
  final bool isLatest;
  final bool groupedWithPrevious;
  final VoidCallback onRetry;

  const _MessageRow({
    required this.message,
    required this.isLatest,
    required this.groupedWithPrevious,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final topGap = groupedWithPrevious ? AppSpace.xs : AppSpace.lg;
    return Padding(
      padding: EdgeInsets.only(top: topGap),
      child: message.isUser
          ? _UserMessage(message: message)
          : _AssistantMessage(message: message, isLatest: isLatest, onRetry: onRetry),
    );
  }
}

class _UserMessage extends StatelessWidget {
  final ChatMessageModel message;
  const _UserMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.sizeOf(context).width * 0.78;
    final hasText = (message.text ?? '').isNotEmpty;
    final isImage = message.attachmentType == ChatAttachmentType.image && message.localPath != null;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isImage)
              Padding(
                padding: EdgeInsets.only(bottom: hasText ? 4 : 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.file(
                    File(message.localPath!),
                    width: 220,
                    fit: BoxFit.cover,
                    cacheWidth: 660,
                    errorBuilder: (_, __, ___) => _AttachmentChip(name: message.fileName ?? 'Image', type: message.attachmentType),
                  ),
                ),
              )
            else if (message.fileName != null)
              Padding(
                padding: EdgeInsets.only(bottom: hasText ? 4 : 0),
                child: _AttachmentChip(name: message.fileName!, type: message.attachmentType),
              ),
            if (hasText)
              GestureDetector(
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  Clipboard.setData(ClipboardData(text: message.text!));
                  showAppSnack('Message copied', tone: SnackTone.success);
                },
                child: Container(
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
                  child: Text(message.text!, style: AppText.body.copyWith(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final String name;
  final ChatAttachmentType? type;
  const _AttachmentChip({required this.name, required this.type});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _attachmentVisual(type);
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(name, style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

(IconData, Color) _attachmentVisual(ChatAttachmentType? type) => switch (type) {
      ChatAttachmentType.image => (Icons.image_rounded, AppColors.info),
      ChatAttachmentType.audio => (Icons.graphic_eq_rounded, AppColors.magenta),
      _ => (Icons.description_rounded, AppColors.warning),
    };

class _AssistantMessage extends StatelessWidget {
  final ChatMessageModel message;
  final bool isLatest;
  final VoidCallback onRetry;

  const _AssistantMessage({required this.message, required this.isLatest, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return Row(
        children: [
          const LabMark(size: 28),
          const SizedBox(width: AppSpace.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Thinking', style: AppText.caption.copyWith(color: AppColors.textSecondary))
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1400.ms, color: Colors.white),
                const SizedBox(width: 8),
                const TypingDots(),
              ],
            ),
          ),
        ],
      );
    }

    if (message.isError) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: AppColors.dangerSoft, shape: BoxShape.circle),
            child: const Icon(Icons.priority_high_rounded, size: 16, color: AppColors.danger),
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Surface(
              padding: const EdgeInsets.all(AppSpace.sm + 2),
              radius: AppRadius.md,
              color: AppColors.dangerSoft,
              borderColor: AppColors.danger.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Message not delivered', style: AppText.label.copyWith(color: AppColors.danger)),
                  if ((message.text ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(message.text!, style: AppText.caption, maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                  if (isLatest) ...[
                    const SizedBox(height: AppSpace.sm),
                    GhostButton(
                      label: 'Try again',
                      icon: Icons.refresh_rounded,
                      expand: false,
                      height: 36,
                      onPressed: onRetry,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    final text = message.text ?? '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LabMark(size: 28),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: GptMarkdown(
                    text,
                    style: AppText.body,
                    onLinkTap: (url, _) {
                      final uri = Uri.tryParse(url);
                      if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              if (message.fileUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: _ResponseFilePreview(url: message.fileUrl!),
                ),
              if (text.isNotEmpty) _MessageActions(text: text),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageActions extends StatefulWidget {
  final String text;
  const _MessageActions({required this.text});

  @override
  State<_MessageActions> createState() => _MessageActionsState();
}

class _MessageActionsState extends State<_MessageActions> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          _TinyAction(
            icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
            label: _copied ? 'Copied' : 'Copy',
            color: _copied ? AppColors.success : AppColors.textTertiary,
            onTap: _copy,
          ),
        ],
      ),
    );
  }
}

class _TinyAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TinyAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          child: Row(
            key: ValueKey(label),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              Text(label, style: AppText.caption.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pending attachment (inside composer) ────────────────────────────────────

class _PendingAttachment extends StatelessWidget {
  final File? file;
  final String name;
  final ChatAttachmentType? type;
  final bool uploading;
  final VoidCallback onClear;

  const _PendingAttachment({
    required this.file,
    required this.name,
    required this.type,
    required this.uploading,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _attachmentVisual(type);
    final isImage = type == ChatAttachmentType.image && file != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surface3,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: SizedBox(
                width: 44,
                height: 44,
                child: isImage
                    ? Image.file(file!, fit: BoxFit.cover, cacheWidth: 132)
                    : ColoredBox(color: color.withValues(alpha: 0.15), child: Icon(icon, color: color, size: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (uploading)
                    const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                      child: LinearProgressIndicator(minHeight: 3),
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('Ready to send', style: AppText.caption.copyWith(color: AppColors.success)),
                      ],
                    ),
                ],
              ),
            ),
            if (!uploading)
              IconButton(
                tooltip: 'Remove attachment',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
              )
            else
              const SizedBox(width: AppSpace.sm),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppMotion.base).scaleXY(begin: 0.96, end: 1, curve: AppMotion.emphasized);
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.92,
        child: Column(
          children: [
            Container(
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Center(child: Icon(icon, color: color, size: 26)),
            ),
            const SizedBox(height: AppSpace.xs),
            Text(label, style: AppText.caption.copyWith(color: AppColors.text)),
          ],
        ),
      ),
    );
  }
}

// ─── Response file previews ──────────────────────────────────────────────────

class _ResponseFilePreview extends StatelessWidget {
  final String url;

  const _ResponseFilePreview({required this.url});

  String get _path => url.toLowerCase().split('?').first;

  bool _endsWithAny(List<String> exts) => exts.any(_path.endsWith);

  bool get _isImage => _endsWithAny(['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp']);
  bool get _isAudio => _endsWithAny(['.mp3', '.wav', '.ogg', '.m4a', '.aac', '.flac', '.opus', '.wma']);
  bool get _isVideo => _endsWithAny(['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v', '.3gp']);

  String get _fileName => Uri.decodeComponent(url.split('/').last.split('?').first);

  IconData get _fileIcon {
    if (_path.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (_endsWithAny(['.xls', '.xlsx', '.csv'])) return Icons.table_chart_rounded;
    if (_endsWithAny(['.ppt', '.pptx'])) return Icons.slideshow_rounded;
    return Icons.description_rounded;
  }

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      showAppSnack('Couldn\'t open the file', tone: SnackTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAudio) return _AudioPlayerWidget(url: url);
    if (_isVideo) return _VideoPlayerWidget(url: url);
    if (_isImage) {
      return GestureDetector(
        onTap: _open,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Skeleton(width: double.infinity, height: 200, radius: AppRadius.lg),
              errorBuilder: (_, __, ___) => _fileCard(),
            ),
          ),
        ),
      );
    }
    return _fileCard();
  }

  Widget _fileCard() {
    return Pressable(
      onTap: _open,
      child: Surface(
        padding: const EdgeInsets.all(AppSpace.sm),
        radius: AppRadius.md,
        color: AppColors.surface2,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.brandSoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(_fileIcon, size: 20, color: AppColors.brand),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_fileName, style: AppText.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const Text('Tap to open', style: AppText.caption),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─── Inline audio player ──────────────────────────────────────────────────────

class _AudioPlayerWidget extends StatefulWidget {
  final String url;
  const _AudioPlayerWidget({required this.url});

  @override
  State<_AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<_AudioPlayerWidget> {
  final _player = AudioPlayer();
  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _state = s);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _position = Duration.zero);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_state == PlayerState.playing) {
      await _player.pause();
    } else if (_state == PlayerState.paused) {
      await _player.resume();
    } else {
      await _player.play(UrlSource(widget.url));
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _state == PlayerState.playing;
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Surface(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      radius: AppRadius.pill,
      color: AppColors.surface2,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: isPlaying ? 'Pause audio' : 'Play audio',
            child: Pressable(
              onTap: _toggle,
              pressedScale: 0.9,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(gradient: AppGradients.brand, shape: BoxShape.circle),
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(isPlaying),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: progress,
              onChanged: _duration.inMilliseconds > 0
                  ? (v) => _player.seek(Duration(milliseconds: (v * _duration.inMilliseconds).round()))
                  : null,
            ),
          ),
          Text(
            '${_fmt(_position)} / ${_fmt(_duration)}',
            style: AppText.caption.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ],
      ),
    );
  }
}

// ─── Inline video player ──────────────────────────────────────────────────────

class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _vpController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _vpController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _vpController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _vpController,
          aspectRatio: _vpController.value.aspectRatio,
          autoPlay: false,
          looping: false,
          placeholder: Container(color: Colors.black),
          materialProgressColors: ChewieProgressColors(
            playedColor: AppColors.brand,
            handleColor: Colors.white,
            backgroundColor: AppColors.brand.withValues(alpha: 0.2),
            bufferedColor: AppColors.brand.withValues(alpha: 0.4),
          ),
        );
      });
    }).catchError((_) {
      if (mounted) setState(() => _hasError = true);
    });
  }

  @override
  void dispose() {
    _vpController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Surface(
        color: AppColors.surface2,
        radius: AppRadius.lg,
        child: const Row(
          children: [
            Icon(Icons.videocam_off_rounded, color: AppColors.textSecondary, size: 20),
            SizedBox(width: AppSpace.sm),
            Text('Couldn\'t load this video', style: AppText.bodySecondary),
          ],
        ),
      );
    }

    if (_chewieController == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Skeleton(width: double.infinity, height: double.infinity, radius: AppRadius.lg),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AspectRatio(
        aspectRatio: _vpController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}
