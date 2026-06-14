class GetAgentsDetailsWithCodeSource {
  num? index;
  String? name;
  String? description;
  String? method;
  String? input_format;
  String? file_path;
  String? synced_at;
  bool? active;
  String? source_code;

  GetAgentsDetailsWithCodeSource({this.index, this.name, this.description, this.method, this.input_format, this.file_path, this.synced_at, this.active, this.source_code});

  factory GetAgentsDetailsWithCodeSource.fromJson(Map<String, dynamic> json) => GetAgentsDetailsWithCodeSource(
    index: json["id"],
    name: json["name"],
    description: json["description"],
    method: json["method"],
    input_format: json["input_format"],
    file_path: json["file_path"],
    synced_at: json["synced_at"],
    active: json["active"],
    source_code: json["source_code"],
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
    "source_code": source_code,
  };
}
