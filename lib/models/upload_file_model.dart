class UploadFilesModel {
  String? file_path;
  List<dynamic>? detail;

  UploadFilesModel({this.file_path, this.detail});

  factory UploadFilesModel.fromJson(Map<String, dynamic> json) => UploadFilesModel(
    file_path: json["file_path"],
    detail: json["detail"] == null ? null : List<dynamic>.from(json["detail"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "file_path": file_path,
    "detail": detail == null ? null : List<dynamic>.from(detail!.map((x) => x)),
  };

}

class DetailFilesModel {
  String? type;
  List<String>? loc;
  String? msg;
  String? input;

  DetailFilesModel({this.type,this.loc,this.msg,this.input});

  factory DetailFilesModel.fromJson(Map<String, dynamic> json) => DetailFilesModel(
    type: json["type"],
    loc: json["loc"] == null ? null : List<String>.from(json["loc"].map((x) => x)),
    msg: json["msg"],
    input: json["input"],
  );

}