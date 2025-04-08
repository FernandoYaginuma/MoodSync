import '../Model/day_model.dart';

class DayController {
  DayModel day;

  DayController({required this.day});

  void updateNote(String newNote) {
    day.note = newNote;
  }

  void setEmotion(String emotion) {
    day.emotion = emotion;
  }

  Map<String, dynamic> toMap() {
    return {
      'date': day.date.toIso8601String(),
      'note': day.note,
      'emotion': day.emotion,
    };
  }

  static DayModel fromMap(Map<String, dynamic> map) {
    return DayModel(
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      emotion: map['emotion'],
    );
  }
}
