import 'package:cloud_firestore/cloud_firestore.dart';

class DayModel {
  final DateTime date;
  String note;
  String? emotion;
  String? professionalId;
  final DateTime? lastUpdatedAt;
  List<String> activityIds;

  DayModel({
    required this.date,
    this.note = '',
    this.emotion,
    this.professionalId,
    this.lastUpdatedAt,
    List<String>? activityIds,
  }) : activityIds = activityIds ?? [];

  // ------------------------------------------------------------
  // 🔵 Converter para Firestore
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'note': note,
      'emotion': emotion,
      'professionalId': professionalId,
      'lastUpdatedAt': lastUpdatedAt != null ? Timestamp.fromDate(lastUpdatedAt!) : null,
      'activityIds': activityIds,
    };
  }

  // ------------------------------------------------------------
  // 🔵 Criar DayModel a partir de um MAP
  // ------------------------------------------------------------
  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      date: (json['date'] as Timestamp).toDate(),
      note: json['note'] ?? '',
      emotion: json['emotion'],
      professionalId: json['professionalId'],
      lastUpdatedAt: (json['lastUpdatedAt'] as Timestamp?)?.toDate(),
      activityIds: List<String>.from(json['activityIds'] ?? []),
    );
  }

  // ------------------------------------------------------------
  // 🔵 Criar DayModel diretamente do Firestore (DocumentSnapshot)
  // ------------------------------------------------------------
  factory DayModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DayModel(
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] ?? '',
      emotion: data['emotion'],
      professionalId: data['professionalId'],
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate(),
      activityIds: List<String>.from(data['activityIds'] ?? []),
    );
  }

  // ------------------------------------------------------------
  // 🔵 Formatador (opcional)
  // ------------------------------------------------------------
  String get formattedDate =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
