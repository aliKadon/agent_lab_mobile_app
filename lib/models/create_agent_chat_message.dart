class CreateAgentChatMessage {
  final String content;
  final bool isUser;
  final bool isProgress;

  /// True for live status events streamed while the lab searches for models.
  final bool isActivity;

  const CreateAgentChatMessage({
    required this.content,
    required this.isUser,
    this.isProgress = false,
    this.isActivity = false,
  });
}
