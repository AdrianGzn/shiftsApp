class AccessLog {
  final int id;
  final int? idUser;
  final int? idVisitor;
  final int idGuard;
  final String eventType;
  final DateTime timestampEvent;
  final String? notes;

  AccessLog({
    required this.id,
    this.idUser,
    this.idVisitor,
    required this.idGuard,
    required this.eventType,
    required this.timestampEvent,
    this.notes,
  });

  factory AccessLog.fromJson(Map<String, dynamic> json) {
    return AccessLog(
      id: json['id'] as int,
      idUser: json['idUser'] as int?,
      idVisitor: json['idVisitor'] as int?,
      idGuard: json['idGuard'] as int,
      eventType: json['event_type'] as String? ?? json['eventType'] as String? ?? 'entry',
      timestampEvent: json['timestamp_event'] != null 
          ? DateTime.parse(json['timestamp_event'].toString()) 
          : DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUser': idUser,
      'idVisitor': idVisitor,
      'idGuard': idGuard,
      'event_type': eventType,
      'timestamp_event': timestampEvent.toIso8601String(),
      'notes': notes,
    };
  }
}
