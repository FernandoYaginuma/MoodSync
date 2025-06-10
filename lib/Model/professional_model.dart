class ProfessionalModel {
  final String id;
  final String name;
  final String specialty;
  final String crp;
  final String phone;
  final String city;

  ProfessionalModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.crp,
    required this.phone,
    required this.city,
  });

  factory ProfessionalModel.fromJson(String id, Map<String, dynamic> json) {
    return ProfessionalModel(
      id: id,
      name: json['name'] ?? 'Nome não informado',
      specialty: json['specialty'] ?? 'Especialidade não informada',
      crp: json['crp'] ?? '',
      phone: json['telefone'] ?? '',
      city: json['cidade'] ?? '',
    );
  }
}