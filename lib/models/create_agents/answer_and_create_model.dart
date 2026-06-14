class AnswerAndCreateModel {
  String? session_id;
  String? step;
  num? agent_id;
  String? name;
  String? method;
  String? file_path;
  String? message;

  AnswerAndCreateModel({this.session_id, this.step, this.agent_id, this.name, this.method, this.file_path, this.message});

  factory AnswerAndCreateModel.fromJson(Map<String, dynamic> json) => AnswerAndCreateModel(
    session_id: json["session_id"],
    step: json["step"],
    agent_id: json["agent_id"],
    name: json["name"],
    method: json["method"],
    file_path: json["file_path"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {"session_id": session_id, "step": step, "agent_id": agent_id, "name": name, "method": method, "file_path": file_path, "message": message};
}

class AnswerAndCreateModelBody {
  String? session_id;
  Map<String, String>? answers;
  List<String>? tool_choices;

  AnswerAndCreateModelBody({this.session_id, this.answers, this.tool_choices});

  Map<String, dynamic> toJson() => {"session_id": session_id, "answers": answers, "tool_choices": tool_choices};
}
