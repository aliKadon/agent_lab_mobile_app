import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/theme/app_tokens.dart';
import 'primitives.dart';

/// The message input shared by Chat and the Create-agent flow.
///
/// A single rounded capsule with an optional leading action ("+"), an
/// auto-growing field and a send button that only lights up once there is
/// something to send.
class Composer extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback? onAttach;
  final bool busy;
  final bool enabled;

  /// Allows sending with an empty text field (e.g. an attachment is pending).
  final bool canSendEmpty;

  /// Rendered above the input row, inside the capsule (attachment previews).
  final Widget? header;

  const Composer({
    super.key,
    required this.controller,
    required this.onSend,
    this.focusNode,
    this.hintText = 'Message',
    this.onAttach,
    this.busy = false,
    this.enabled = true,
    this.canSendEmpty = false,
    this.header,
  });

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();
  bool _hasText = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onText);
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(covariant Composer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
      _onText();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  void _onText() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  void _onFocus() => setState(() => _focused = _focus.hasFocus);

  bool get _canSend => widget.enabled && !widget.busy && (_hasText || widget.canSendEmpty);

  void _send() {
    if (!_canSend) return;
    HapticFeedback.lightImpact();
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.base,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: _focused ? AppColors.brand.withValues(alpha: 0.55) : AppColors.borderStrong,
        ),
        boxShadow: _focused
            ? [BoxShadow(color: AppColors.brand.withValues(alpha: 0.12), blurRadius: 24, spreadRadius: 2)]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: AppMotion.base,
            curve: AppMotion.emphasized,
            alignment: Alignment.topCenter,
            child: widget.header ?? const SizedBox(width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.onAttach != null)
                  CircleIconButton(
                    icon: Icons.add_rounded,
                    tooltip: 'Attach',
                    size: 40,
                    background: AppColors.surface3,
                    onPressed: widget.enabled && !widget.busy ? widget.onAttach : null,
                  )
                else
                  const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    enabled: widget.enabled,
                    minLines: 1,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppText.body,
                    cursorColor: AppColors.brand,
                    onTapOutside: (_) => _focus.unfocus(),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      filled: false,
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    ),
                  ),
                ),
                _SendButton(enabled: _canSend, busy: widget.busy, onTap: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool busy;
  final VoidCallback onTap;

  const _SendButton({required this.enabled, required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: enabled ? onTap : null,
      pressedScale: 0.88,
      haptic: false,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.emphasized,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: enabled || busy ? AppGradients.brand : null,
          color: enabled || busy ? null : AppColors.surface3,
        ),
        child: AnimatedSwitcher(
          duration: AppMotion.fast,
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: busy
              ? const Padding(
                  key: ValueKey('busy'),
                  padding: EdgeInsets.all(11),
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(
                  Icons.arrow_upward_rounded,
                  key: const ValueKey('send'),
                  size: 21,
                  color: enabled ? Colors.white : AppColors.textTertiary,
                ),
        ),
      ),
    );
  }
}
