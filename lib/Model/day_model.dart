import 'package:cloud_firestore/cloud_firestore.dart';

class DayModel {
  final DateTime date;
  String note;
  String? emotion;

  DayModel({
    required this.date,
    this.note = '',
    this.emotion,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': Timestamp.fromDate(date),
      'note': note,
      'emotion': emotion,
    };
  }

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      date: (json['date'] as Timestamp).toDate(),
      note: json['note'] ?? '',
      emotion: json['emotion'],
    );
  }

  String get formattedDate =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}