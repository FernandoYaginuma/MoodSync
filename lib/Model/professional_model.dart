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
      name: (json['nome'] ?? 'Nome não informado').toString(),
      specialty: (json['especialidade'] ?? 'Especialidade não informada').toString(),
      crp: (json['registroProfissional'] ?? '').toString(),
      phone: (json['telefone'] ?? '').toString(),
      city: (json['cidade'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': name,
    'especialidade': specialty,
    'registroProfissional': crp,
    'telefone': phone,
    'cidade': city,
  };
}
