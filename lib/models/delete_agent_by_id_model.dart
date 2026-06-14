class DeleteAgentByIdModel {
  num? id;
  String? name;
  String? message;

  DeleteAgentByIdModel({this.id,this.name,this.message});

  factory DeleteAgentByIdModel.fromJson(Map<String, dynamic> json) => DeleteAgentByIdModel(
    id: json["id"],
    name: json["name"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "message": message,
  };

}