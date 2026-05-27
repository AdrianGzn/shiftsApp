class Organization {
  final int id;
  final String name;
  final String type;
  final String address;
  final DateTime? createdAt;

  Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'empresa',
      address: json['address'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Organization copyWith({
    int? id,
    String? name,
    String? type,
    String? address,
    DateTime? createdAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
