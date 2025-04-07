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
}
