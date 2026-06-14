import 'dart:io';
import 'package:file_picker/file_picker.dart';

class CustomFilePicker {
  //! Generic function to pick a file with given allowed extensions
  static Future<File?> pickFile({required List<String> allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: allowedExtensions,
      withReadStream: false,
    );

    return result?.files.single.path != null ? File(result!.files.single.path!) : null;
  }

  //! Pick a document file
  static Future<File?> pickDocument() async {
    return pickFile(allowedExtensions: ['docx', 'doc', 'pdf', 'epub', 'txt', 'ppt', 'pptx', 'xls', 'xlsx', 'csv']);
  }

  //! Pick an audio file
  static Future<File?> pickAudio() async {
    return pickFile(allowedExtensions: ["m4a", "mp3", "wav"]);
  }

  //! Pick a video file
  static Future<File?> pickVideo() async {
    return pickFile(allowedExtensions: ["mp4"]);
  }
}
