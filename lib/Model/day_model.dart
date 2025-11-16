import 'package:cloud_firestore/cloud_firestore.dart';

class DayModel {
  final DateTime date;
  String note;
  List<String> emotions; // lista de emoções
  String? professionalId;
  final DateTime? lastUpdatedAt;
  List<String> activityIds;

  DayModel({
    required this.date,
    this.note = '',
    List<String>? emotions,
    this.professionalId,
    this.lastUpdatedAt,
    List<String>? activityIds,
  })  : emotions = emotions ?? [],
        activityIds = activityIds ?? [];

  // ------------------------------------------------------------
  // Converter para Firestore
  // ------------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'note': note,
      'emotions': emotions,
      'professionalId': professionalId,
      'lastUpdatedAt':
      lastUpdatedAt != null ? Timestamp.fromDate(lastUpdatedAt!) : null,
      'activityIds': activityIds,
    };
  }

  // ------------------------------------------------------------
  // Criar a partir de JSON (compatível com versões antigas)
  // ------------------------------------------------------------
  factory DayModel.fromJson(Map<String, dynamic> json) {
    final legacyEmotion = json['emotion'];

    final List<String> emotionsList =
    json['emotions'] != null
        ? List<String>.from(json['emotions'])
        : (legacyEmotion != null ? [legacyEmotion as String] : []);

    return DayModel(
      date: (json['date'] as Timestamp).toDate(),
      note: json['note'] ?? '',
      emotions: emotionsList,
      professionalId: json['professionalId'],
      lastUpdatedAt: (json['lastUpdatedAt'] as Timestamp?)?.toDate(),
      activityIds: List<String>.from(json['activityIds'] ?? []),
    );
  }

  // ------------------------------------------------------------
  // Criar DayModel diretamente do Firestore
  // ------------------------------------------------------------
  factory DayModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final legacyEmotion = data['emotion'];

    final List<String> emotionsList =
    data['emotions'] != null
        ? List<String>.from(data['emotions'])
        : (legacyEmotion != null ? [legacyEmotion as String] : []);

    return DayModel(
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] ?? '',
      emotions: emotionsList,
      professionalId: data['professionalId'],
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate(),
      activityIds: List<String>.from(data['activityIds'] ?? []),
    );
  }

  // ------------------------------------------------------------
  // Helper: ID do documento
  // ------------------------------------------------------------
  String get formattedDate =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}
