class DayModel {
  final DateTime date;
  String note;
  String? emotion;

  DayModel({
    required this.date,
    this.note = '',
    this.emotion,
  });

  String get formattedDate => "${date.year}-${date.month}-${date.day}";
}
