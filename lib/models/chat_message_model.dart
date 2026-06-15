import 'package:agent_lab/utils/constants/app_enums.dart';

class ChatMessageModel {
  final String? text;
  final bool isUser;
  final String? fileName;
  final ChatAttachmentType? attachmentType;
  final bool isLoading;
  final String? fileUrl;

  const ChatMessageModel({
    this.text,
    required this.isUser,
    this.fileName,
    this.attachmentType,
    this.isLoading = false,
    this.fileUrl,
  });
}