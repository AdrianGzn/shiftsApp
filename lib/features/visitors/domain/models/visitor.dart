class Visitor {
  final int id;
  final String fullName;
  final String? documentId;
  final String? company;
  final String reason;
  final String? phone;
  final DateTime? createdAt;

  Visitor({
    required this.id,
    required this.fullName,
    this.documentId,
    this.company,
    required this.reason,
    this.phone,
    this.createdAt,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'] as int,
      fullName: json['fullName'] as String? ?? json['fullname'] as String? ?? '',
      documentId: json['document_id'] as String? ?? json['documentId'] as String?,
      company: json['company'] as String?,
      reason: json['reason'] as String? ?? '',
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'document_id': documentId,
      'company': company,
      'reason': reason,
      'phone': phone,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Visitor copyWith({
    int? id,
    String? fullName,
    String? documentId,
    String? company,
    String? reason,
    String? phone,
    DateTime? createdAt,
  }) {
    return Visitor(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      documentId: documentId ?? this.documentId,
      company: company ?? this.company,
      reason: reason ?? this.reason,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
