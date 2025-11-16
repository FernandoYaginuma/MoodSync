import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/Model/mural_model.dart';

class MuralController {
  final String pacienteId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MuralController(this.pacienteId);

  /// 🔵 Stream das mensagens
  Stream<List<MuralMessage>> getMensagens() {
    return _firestore
        .collection("users")
        .doc(pacienteId)
        .collection("mural")
        .orderBy("criadoEm", descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => MuralMessage.fromFirestore(d)).toList());
  }

  /// 🔵 Enviar mensagem
  Future<void> enviarMensagem({
    required String texto,
    required String autor,
  }) async {
    await _firestore
        .collection("users")
        .doc(pacienteId)
        .collection("mural")
        .add({
      "texto": texto,
      "autor": autor,
      "criadoEm": Timestamp.now(),
      "lido": false,
    });
  }

  /// 🔵 Marcar como lida (somente paciente)
  Future<void> marcarComoLida(String msgId) async {
    await _firestore
        .collection("users")
        .doc(pacienteId)
        .collection("mural")
        .doc(msgId)
        .update({"lido": true});
  }

  /// 🔵 Apagar (apenas profissional)
  Future<void> apagarMensagem(String msgId) async {
    await _firestore
        .collection("users")
        .doc(pacienteId)
        .collection("mural")
        .doc(msgId)
        .delete();
  }
}
