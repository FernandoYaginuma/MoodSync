class PatientModel {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String sexo;
  final String? dataNascimento;
  final List<String> profissionaisVinculados;

  PatientModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.sexo,
    required this.dataNascimento,
    required this.profissionaisVinculados,
  });

  factory PatientModel.fromJson(String id, Map<String, dynamic> json) {
    return PatientModel(
      id: id,
      nome: json['nome'] ?? 'Nome não informado',
      email: json['email'] ?? 'E-mail não informado',
      telefone: json['telefone'] ?? '',
      sexo: json['sexo'] ?? 'Prefiro não informar',
      dataNascimento: json['dataNascimento']?.toString(),
      profissionaisVinculados: List<String>.from(
        json['profissionaisVinculados'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'sexo': sexo,
      'dataNascimento': dataNascimento,
      'profissionaisVinculados': profissionaisVinculados,
    };
  }
}
