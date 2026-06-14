class PickAModel {
  String? session_id;
  String? step;
  String? selected_model;
  List<String>? clarifying_questions;
  List<SuggestedTools>? suggested_tools;
  String? message;

  PickAModel({this.message, this.clarifying_questions, this.selected_model, this.session_id, this.step, this.suggested_tools});

  factory PickAModel.fromJson(Map<String, dynamic> json) => PickAModel(
    session_id: json["session_id"],
    clarifying_questions: json["clarifying_questions"] == null ? null : List<String>.from(json["clarifying_questions"].map((x) => x)),
    message: json["message"],
    selected_model: json["selected_model"],
    step: json["step"],
    suggested_tools: json["suggested_tools"] == null ? null : List<SuggestedTools>.from(json["suggested_tools"].map((x) => SuggestedTools.fromJson(x))),
  );
}

class PickAModelBody {
  String? session_id;
  num? model_choice;

  PickAModelBody({this.session_id,this.model_choice});

  factory PickAModelBody.fromJson(Map<String, dynamic> json) => PickAModelBody(session_id: json["session_id"], model_choice: json["model_choice"]);

  Map<String, dynamic> toJson() => {"session_id": session_id, "model_choice": model_choice};
}

class SuggestedTools {
  String? name;
  String? description;

  SuggestedTools({this.name, this.description});

  factory SuggestedTools.fromJson(Map<String, dynamic> json) => SuggestedTools(name: json["name"], description: json["description"]);

  Map<String, dynamic> toJson() => {"name": name, "description": description};
}