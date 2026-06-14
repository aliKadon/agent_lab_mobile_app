import 'dart:io';

import 'package:agent_lab/models/chat_message_model.dart';
import 'package:agent_lab/providers/main_provider.dart';
import 'package:agent_lab/utils/constants/app_enums.dart';
import 'package:agent_lab/utils/constants/pallete.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final AnimationController _typingController;

  File? _pendingFile;
  String? _pendingFileName;
  ChatAttachmentType? _pendingType;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
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

  Future<void> _pickAttachment(ChatAttachmentType type) async {
    Navigator.pop(context);
    File? picked;
    String? name;

    try {
      if (type == ChatAttachmentType.image) {
        final img = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (img == null) return;
        picked = File(img.path);
        name = img.name;
      } else if (type == ChatAttachmentType.audio) {
        final result = await FilePicker.platform.pickFiles(type: FileType.audio);
        if (result == null || result.files.isEmpty) return;
        picked = File(result.files.first.path!);
        name = result.files.first.name;
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx', 'csv'],
        );
        if (result == null || result.files.isEmpty) return;
        picked = File(result.files.first.path!);
        name = result.files.first.name;
      }
    } catch (_) {
      return;
    }

    setState(() {
      _isUploading = true;
      _pendingFile = picked;
      _pendingFileName = name;
      _pendingType = type;
    });

    await ref.read(mainProviderStateProvider.notifier).uploadChatAttachment(
      file: picked!,
      onResult: (success) {
        if (mounted) {
          setState(() => _isUploading = false);
          if (!success) {
            setState(() {
              _pendingFile = null;
              _pendingFileName = null;
              _pendingType = null;
            });
          }
        }
      },
    );
  }

  Future<void> _pickFromCamera() async {
    Navigator.pop(context);
    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img == null || !mounted) return;

    final file = File(img.path);
    setState(() {
      _isUploading = true;
      _pendingFile = file;
      _pendingFileName = img.name;
      _pendingType = ChatAttachmentType.image;
    });

    await ref.read(mainProviderStateProvider.notifier).uploadChatAttachment(
      file: file,
      onResult: (success) {
        if (mounted) {
          setState(() => _isUploading = false);
          if (!success) {
            setState(() {
              _pendingFile = null;
              _pendingFileName = null;
              _pendingType = null;
            });
          }
        }
      },
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Pallete.grey19,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Pallete.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: Colors.blueAccent,
                    onTap: () => _pickAttachment(ChatAttachmentType.image),
                  ),
                  _AttachOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: Colors.green,
                    onTap: _pickFromCamera,
                  ),
                  _AttachOption(
                    icon: Icons.insert_drive_file_outlined,
                    label: 'Document',
                    color: Colors.orange,
                    onTap: () => _pickAttachment(ChatAttachmentType.document),
                  ),
                  _AttachOption(
                    icon: Icons.mic_outlined,
                    label: 'Audio',
                    color: Pallete.primary,
                    onTap: () => _pickAttachment(ChatAttachmentType.audio),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _pendingFileName == null) return;

    final attachmentName = _pendingFileName;
    final attachmentType = _pendingType;

    _textController.clear();
    setState(() {
      _pendingFile = null;
      _pendingFileName = null;
      _pendingType = null;
    });

    _scrollToBottom();

    await ref.read(mainProviderStateProvider.notifier).sendChatMessage(
      message: text,
      attachmentName: attachmentName,
      attachmentType: attachmentType,
    );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainProviderStateProvider);
    final messages = state.chatMessages;
    final isSending = state.isSendingMessage;

    if (messages.isNotEmpty) _scrollToBottom();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _EmptyChat(onSuggestionTap: (text) {
                    _textController.text = text;
                  })
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return _ChatBubble(
                        message: msg,
                        typingController: _typingController,
                      );
                    },
                  ),
          ),
          _BottomBar(
            controller: _textController,
            isUploading: _isUploading,
            isSending: isSending,
            pendingFileName: _pendingFileName,
            pendingType: _pendingType,
            onClearAttachment: () => setState(() {
              _pendingFile = null;
              _pendingFileName = null;
              _pendingType = null;
            }),
            onAttachTap: _showAttachmentSheet,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyChat extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  const _EmptyChat({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'What can you help me with?',
      'Summarize a document for me',
      'Analyze this file',
    ];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Pallete.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, color: Pallete.primary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Start a conversation',
            style: TextStyle(color: Pallete.white, fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ask anything or share a file',
            style: TextStyle(color: Pallete.grey, fontSize: 13),
          ),
          const SizedBox(height: 28),
          ...suggestions.map(
            (s) => GestureDetector(
              onTap: () => onSuggestionTap(s),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Pallete.grey19,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Pallete.primary.withValues(alpha: 0.3)),
                ),
                child: Text(s, style: const TextStyle(color: Pallete.white, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat bubble ─────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final AnimationController typingController;

  const _ChatBubble({required this.message, required this.typingController});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Pallete.primary : Pallete.grey19,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: message.isLoading
            ? _TypingIndicator(controller: typingController)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.fileName != null)
                    _FileChip(
                      name: message.fileName!,
                      type: message.attachmentType,
                      isUser: isUser,
                    ),
                  if (message.text != null && message.text!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: message.fileName != null ? 6 : 0),
                      child: Text(
                        message.text!,
                        style: TextStyle(
                          color: isUser ? Pallete.white : Pallete.white,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final String name;
  final ChatAttachmentType? type;
  final bool isUser;

  const _FileChip({required this.name, required this.type, required this.isUser});

  IconData get _icon {
    switch (type) {
      case ChatAttachmentType.image:
        return Icons.image_outlined;
      case ChatAttachmentType.audio:
        return Icons.audio_file_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withValues(alpha: 0.15)
            : Pallete.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 15, color: isUser ? Pallete.white : Pallete.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: isUser ? Pallete.white : Pallete.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final AnimationController controller;

  const _TypingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.25;
            final t = ((controller.value + delay) % 1.0);
            final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Opacity(
                opacity: opacity,
                child: const CircleAvatar(
                  radius: 4,
                  backgroundColor: Pallete.grey,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Bottom input bar ─────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isUploading;
  final bool isSending;
  final String? pendingFileName;
  final ChatAttachmentType? pendingType;
  final VoidCallback onClearAttachment;
  final VoidCallback onAttachTap;
  final VoidCallback onSend;

  const _BottomBar({
    required this.controller,
    required this.isUploading,
    required this.isSending,
    required this.pendingFileName,
    required this.pendingType,
    required this.onClearAttachment,
    required this.onAttachTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Pallete.darkBg,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pendingFileName != null || isUploading)
              _PendingAttachmentChip(
                name: pendingFileName ?? 'Uploading…',
                type: pendingType,
                isUploading: isUploading,
                onClear: onClearAttachment,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (isSending || isUploading) ? null : onAttachTap,
                    icon: const Icon(Icons.attach_file_rounded),
                    color: Pallete.primary,
                    iconSize: 22,
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !isSending,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(color: Pallete.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        hintStyle: const TextStyle(color: Pallete.grey, fontSize: 14),
                        filled: true,
                        fillColor: Pallete.grey19,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: (isSending || isUploading) ? null : onSend,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (isSending || isUploading)
                            ? Pallete.primary.withValues(alpha: 0.4)
                            : Pallete.primary,
                        shape: BoxShape.circle,
                      ),
                      child: isSending
                          ? const Padding(
                              padding: EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Pallete.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Pallete.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingAttachmentChip extends StatelessWidget {
  final String name;
  final ChatAttachmentType? type;
  final bool isUploading;
  final VoidCallback onClear;

  const _PendingAttachmentChip({
    required this.name,
    required this.type,
    required this.isUploading,
    required this.onClear,
  });

  IconData get _icon {
    switch (type) {
      case ChatAttachmentType.image:
        return Icons.image_outlined;
      case ChatAttachmentType.audio:
        return Icons.audio_file_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Pallete.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Pallete.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUploading)
                  const SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Pallete.primary),
                  )
                else
                  Icon(_icon, size: 14, color: Pallete.primary),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    name,
                    style: const TextStyle(color: Pallete.primary, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (!isUploading)
            GestureDetector(
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.close, size: 16, color: Pallete.grey),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Attachment option tile ───────────────────────────────────────────────────

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Pallete.grey, fontSize: 12)),
        ],
      ),
    );
  }
}