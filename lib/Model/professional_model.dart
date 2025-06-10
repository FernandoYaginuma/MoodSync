class ProfessionalModel {
  final String id;
  final String name;
  final String specialty;

  ProfessionalModel({
    required this.id,
    required this.name,
    required this.specialty,
  });

  factory ProfessionalModel.fromJson(String id, Map<String, dynamic> json) {
    return ProfessionalModel(
      id: id,
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? '',
    );
  }
}