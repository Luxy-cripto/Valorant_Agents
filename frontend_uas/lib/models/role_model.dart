class RoleModel {
  final int id;
  final int userId;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  RoleModel({
    required this.id,
    required this.userId,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}