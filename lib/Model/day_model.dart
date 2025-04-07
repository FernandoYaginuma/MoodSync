class DayModel {
  final DateTime date;
  String note;
  String? emotion;

  DayModel({
    required this.date,
    this.note = '',
    this.emotion,
  });
}
