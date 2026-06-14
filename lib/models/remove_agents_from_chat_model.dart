class AddRemoveAgentsFromChatModel {
  String? message;
  List<String>? active_agents;

  AddRemoveAgentsFromChatModel({this.message,this.active_agents});

  factory AddRemoveAgentsFromChatModel.fromJson(Map<String, dynamic> json) => AddRemoveAgentsFromChatModel(
    message: json["message"],
    active_agents: json["active_agents"] == null ? null : List<String>.from(json["active_agents"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "active_agents": active_agents == null ? null : List<dynamic>.from(active_agents!.map((x) => x)),
  };

}