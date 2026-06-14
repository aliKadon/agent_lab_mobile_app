class GetActiveAgentsInChatModel {
  final String? name;
  final String? description;
  final String? method;
  final bool? active;

  GetActiveAgentsInChatModel({
     this.name,
     this.description,
     this.method,
     this.active,
  });

  factory GetActiveAgentsInChatModel.fromJson(Map<String, dynamic> json) {
    return GetActiveAgentsInChatModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      method: json['method'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'method': method,
      'active': active,
    };
  }

  GetActiveAgentsInChatModel copyWith({
    String? name,
    String? description,
    String? method,
    bool? active,
  }) {
    return GetActiveAgentsInChatModel(
      name: name ?? this.name,
      description: description ?? this.description,
      method: method ?? this.method,
      active: active ?? this.active,
    );
  }
}