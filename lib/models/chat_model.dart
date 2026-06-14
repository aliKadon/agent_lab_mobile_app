class ChatModel {
  String? reply;
  String? session_id;
  String? file_url;
  String? details;

  ChatModel({this.session_id,this.file_url,this.reply,this.details,});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
    session_id: json["session_id"],
    file_url: json["file_url"],
    reply: json["reply"],
    details: json["details"],
  );

  Map<String, dynamic> toJson() => {
    "session_id": session_id,
    "file_url": file_url,
    "reply": reply,
    "details": details,
  };

}


class ChatBody {
  String? session_id;
  String? message;

  ChatBody({this.session_id,this.message});

  factory ChatBody.fromJson(Map<String, dynamic> json) => ChatBody(
    session_id: json["session_id"],
    message: json["message"],
  );


  Map<String, dynamic> toJson() => {
    "session_id": session_id,
    "message": message,
  };

}