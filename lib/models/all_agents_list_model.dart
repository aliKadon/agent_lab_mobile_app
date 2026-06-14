class AllAgentsList {
  num? total;
  List<AgentModel>? agents;

  AllAgentsList({this.total, this.agents});

  factory AllAgentsList.fromJson(Map<String, dynamic> json) =>
      AllAgentsList(total: json["total"], agents: json["agents"] == null ? null : List<AgentModel>.from(json["agents"].map((x) => AgentModel.fromJson(x))));

  Map<String, dynamic> toJson() => {"total": total, "agents": agents};
}

class AgentModel {
  num? index;
  String? name;
  String? description;
  String? method;
  String? input_format;
  String? file_path;
  String? synced_at;
  bool? active;

  AgentModel({this.index, this.name, this.description, this.method, this.input_format, this.file_path, this.synced_at, this.active});

  factory AgentModel.fromJson(Map<String, dynamic> json) => AgentModel(
    index: json["id"],
    name: json["name"],
    description: json["description"],
    method: json["method"],
    input_format: json["input_format"],
    file_path: json["file_path"],
    synced_at: json["synced_at"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "index": index,
    "name": name,
    "description": description,
    "method": method,
    "input_format": input_format,
    "file_path": file_path,
    "synced_at": synced_at,
    "active": active,
  };
}
