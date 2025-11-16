import 'package:cloud_firestore/cloud_firestore.dart';

class MuralMessage {
  final String id;
  final String texto;
  final String autor;
  final bool lido;
  final DateTime criadoEm;

  MuralMessage({
    required this.id,
    required this.texto,
    required this.autor,
    required this.lido,
    required this.criadoEm,
  });

  factory MuralMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MuralMessage(
      id: doc.id,
      texto: data["texto"] ?? "",
      autor: data["autor"] ?? "desconhecido",
      lido: data["lido"] ?? false,
      criadoEm: (data["criadoEm"] as Timestamp).toDate(),
    );
  }
}
