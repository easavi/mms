class CreateUserRequest {
  final String email;
  final String name;
  final String? description;

  CreateUserRequest({
    required this.email,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'description': description,
    };
  }
}

class UpdateUserRequest {
  final String? email;
  final String? name;
  final String? description;

  UpdateUserRequest({
    this.email,
    this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (email != null) json['email'] = email;
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    return json;
  }
}
