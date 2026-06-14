import 'package:agent_lab/utils/constants/app_enums.dart';

class ChatMessageModel {
  final String? text;
  final bool isUser;
  final String? fileName;
  final ChatAttachmentType? attachmentType;
  final bool isLoading;

  const ChatMessageModel({
    this.text,
    required this.isUser,
    this.fileName,
    this.attachmentType,
    this.isLoading = false,
  });
}