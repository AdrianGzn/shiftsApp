class UserModel {
  final int id;
  final String name;
  final String? email;
  final String role;
  final int? idOrganization;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    this.idOrganization,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['mail'] as String? ?? json['email'] as String?,
      role: json['role'] as String? ?? 'empleado',
      idOrganization: json['idOrganization'] as int? ?? json['id_organization'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mail': email,
      'role': role,
      'idOrganization': idOrganization,
    };
  }
}
