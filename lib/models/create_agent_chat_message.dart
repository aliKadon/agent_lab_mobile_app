class CreateAgentChatMessage {
  final String content;
  final bool isUser;
  final bool isProgress;

  const CreateAgentChatMessage({
    required this.content,
    required this.isUser,
    this.isProgress = false,
  });
}