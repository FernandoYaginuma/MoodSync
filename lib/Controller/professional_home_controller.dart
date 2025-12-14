import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:android2/Model/patient_model.dart';

class ProfessionalHomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lista reativa de pacientes já ACEITOS
  final ValueNotifier<List<PatientModel>> pacientes = ValueNotifier([]);

  // ============================================================
  // 🔵 CARREGAR PACIENTES VINCULADOS (ACEITOS)
  // ============================================================
  Future<void> carregarPacientes(String profissionalId) async {
    try {
      final doc = await _firestore
          .collection('profissional_pacientes')
          .doc(profissionalId)
          .get();

      if (!doc.exists) {
        pacientes.value = [];
        return;
      }

      final List<dynamic> ids = doc.data()?['pacientes'] ?? [];

      if (ids.isEmpty) {
        pacientes.value = [];
        return;
      }

      final snap = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      pacientes.value =
          snap.docs.map((d) => PatientModel.fromJson(d.id, d.data())).toList();
    } catch (e) {
      debugPrint("❌ Erro ao carregar pacientes: $e");
    }
  }

  // ============================================================
  // 🔔 ENVIAR / REENVIAR SOLICITAÇÃO DE VÍNCULO
  // ============================================================
  Future<String?> adicionarPaciente(
    String profissionalId,
    String profissionalNome,
    String email,
  ) async {
    try {
      // 1 ▸ Verifica se o paciente existe
      final snap = await _firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .where("role", isEqualTo: "paciente")
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        return "Paciente não encontrado.";
      }

      final pacienteId = snap.docs.first.id;

      // 2 ▸ Verifica se já existe solicitação
      final existing = await _firestore
          .collection("vinculacoes")
          .where("profissionalId", isEqualTo: profissionalId)
          .where("pacienteEmail", isEqualTo: email)
          .limit(1)
          .get();

      // 🔁 Se existir → reseta para pendente
      if (existing.docs.isNotEmpty) {
        await existing.docs.first.reference.update({
          "status": "pendente",
          "createdAt": FieldValue.serverTimestamp(),
          "createdBy": "profissional",
          // opcional (bom pra consistência)
          "pacienteId": pacienteId,
        });
        return null;
      }

      // 🆕 Se não existir → cria nova
      await _firestore.collection("vinculacoes").add({
        "profissionalId": profissionalId,
        "profissionalNome": profissionalNome,
        "pacienteEmail": email,
        "pacienteId": pacienteId, // ✅ salva também o id
        "status": "pendente",
        "createdAt": FieldValue.serverTimestamp(),
        "createdBy": "profissional",
      });

      return null;
    } catch (e) {
      debugPrint("❌ Erro ao enviar solicitação: $e");
      return "Erro ao enviar solicitação.";
    }
  }

  // ============================================================
  // ❌ DESVINCULAR PACIENTE (3 coleções)
  // ============================================================
  Future<String?> desvincularPaciente({
    required String profissionalId,
    required String pacienteId,
  }) async {
    try {
      // 1) Remove do profissional → pacientes
      final docProf = _firestore
          .collection("profissional_pacientes")
          .doc(profissionalId);

      if ((await docProf.get()).exists) {
        await docProf.update({
          "pacientes": FieldValue.arrayRemove([pacienteId]),
        });
      }

      // 2) Remove do paciente → profissionais
      final docPaciente =
          _firestore.collection("paciente_profissionais").doc(pacienteId);

      if ((await docPaciente.get()).exists) {
        await docPaciente.update({
          "profissionais": FieldValue.arrayRemove([profissionalId]),
        });
      }

      // 3) Remove do users do paciente
      final userDoc = _firestore.collection("users").doc(pacienteId);
      if ((await userDoc.get()).exists) {
        await userDoc.update({
          "profissionaisVinculados": FieldValue.arrayRemove([profissionalId]),
        });
      }

      // 4) Atualiza lista local (UI)
      final atual = List<PatientModel>.from(pacientes.value);
      atual.removeWhere((p) => p.id == pacienteId);
      pacientes.value = atual;

      return null;
    } catch (e) {
      debugPrint("❌ Erro ao desvincular paciente: $e");
      return "Erro ao desvincular paciente.";
    }
  }
}
