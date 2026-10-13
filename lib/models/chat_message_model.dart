import 'package:agent_lab/utils/constants/app_enums.dart';

class ChatMessageModel {
  final String? text;
  final bool isUser;
  final String? fileName;
  final ChatAttachmentType? attachmentType;
  final bool isLoading;
  final String? fileUrl;

  /// Local path of an attachment the user sent, used to render a thumbnail.
  final String? localPath;

  /// Server-side path of the uploaded attachment, kept so a failed send can be retried.
  final String? uploadedPath;

  /// True when this assistant message represents a failed request.
  final bool isError;

  const ChatMessageModel({
    this.text,
    required this.isUser,
    this.fileName,
    this.attachmentType,
    this.isLoading = false,
    this.fileUrl,
    this.localPath,
    this.uploadedPath,
    this.isError = false,
  });
}
