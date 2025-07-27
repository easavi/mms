class Tag {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  Tag({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays > 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays > 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
