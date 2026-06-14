class SearchModelsReturnListToPickFromModel {
  String? session_id;
  String? step;
  Debug? debug;
  List<AgentModels>? models;

  SearchModelsReturnListToPickFromModel({this.session_id, this.step, this.debug, this.models});

  factory SearchModelsReturnListToPickFromModel.fromJson(Map<String, dynamic> json) => SearchModelsReturnListToPickFromModel(session_id: json["session_id"], step: json["step"], debug: json["_debug"], models: json["models"] == null ? null : List<AgentModels>.from(json["models"].map((x) => AgentModels.fromJson(x)))  );

  Map<String, dynamic> toJson() => {"session_id": session_id, "step": step, "_debug": debug, "models": models};


}

class Debug {
  num? total_candidates;
  num? with_provider;
  num? shown;

  Debug({this.total_candidates, this.with_provider, this.shown});

  factory Debug.fromJson(Map<String, dynamic> json) => Debug(total_candidates: json["total_candidates"], with_provider: json["with_provider"], shown: json["shown"]);

  Map<String, dynamic> toJson() => {"total_candidates": total_candidates, "with_provider": with_provider, "shown": shown};
}

class AgentModels {
  num? index;
  String? name;
  String? provider;
  String? method;
  bool? has_chat_template;
  bool? gated;
  String? license;
  bool? usable;

  AgentModels({this.index, this.name, this.provider, this.method, this.has_chat_template, this.gated, this.license, this.usable});

  factory AgentModels.fromJson(Map<String, dynamic> json) => AgentModels(
    index: json["index"],
    name: json["name"],
    provider: json["provider"],
    method: json["method"],
    has_chat_template: json["has_chat_template"],
    gated: json["gated"],
    license: json["license"],
    usable: json["usable"],
  );

  Map<String, dynamic> toJson() => {"index": index, "name": name, "provider": provider, "method": method, "has_chat_template": has_chat_template, "gated": gated, "license": license, "usable": usable};
}

class ProgressStatus {
  String? status;
  String? message;

  ProgressStatus({this.status, this.message});

  factory ProgressStatus.fromJson(Map<String, dynamic> json) => ProgressStatus(status: json["status"], message: json["message"]);

  Map<String, dynamic> toJson() => {"status": status, "message": message};
}