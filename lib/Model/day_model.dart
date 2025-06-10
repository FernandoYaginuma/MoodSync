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

  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'note': note,
      'emotion': emotion,
      'professionalId': professionalId,
      'activityIds': activityIds,
    };
  }

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

  String get formattedDate =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}