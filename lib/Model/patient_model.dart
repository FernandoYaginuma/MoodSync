class PatientModel {
  final String id;
  final String nome;
  final String email;

  PatientModel({
    required this.id,
    required this.nome,
    required this.email,
  });

  factory PatientModel.fromJson(String id, Map<String, dynamic> json) {
    return PatientModel(
      id: id,
      nome: json['nome'] ?? 'Nome não informado',
      email: json['email'] ?? 'E-mail não informado',
    );
  }

  Map<String, dynamic> toJson() => {
    'nome': nome,
    'email': email,
  };
}
