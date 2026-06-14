class RescanDiskAndUpdateTheDatabaseModel {
  num? total;
  String? message;

  RescanDiskAndUpdateTheDatabaseModel({this.message,this.total});

  factory RescanDiskAndUpdateTheDatabaseModel.fromJson(Map<String, dynamic> json) => RescanDiskAndUpdateTheDatabaseModel(
    message: json["message"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "total": total,
  };

}