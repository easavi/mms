class CreateTagRequest {
  final String name;
  final String? description;

  CreateTagRequest({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

class UpdateTagRequest {
  final String? name;
  final String? description;

  UpdateTagRequest({
    this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    return json;
  }
}
