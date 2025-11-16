import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:android2/Model/patient_model.dart';

class ProfessionalHomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lista reativa de pacientes do profissional
  final ValueNotifier<List<PatientModel>> pacientes = ValueNotifier([]);

  // ============================================================
  // 🔵 CARREGAR PACIENTES VINCULADOS
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

      List<dynamic> ids = doc.data()?['pacientes'] ?? [];

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
  // 🔵 ADICIONAR PACIENTE AO PROFISSIONAL
  // (corrigido com atualização no users/)
  // ============================================================
  Future<String?> adicionarPaciente(
      String profissionalId, String email) async {
    try {
      // 1 ▸ Buscar usuário pelo e-mail e verificar se é paciente
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

      // 2 ▸ Buscar lista de profissionais já vinculados
      final pacienteDoc = await _firestore
          .collection("paciente_profissionais")
          .doc(pacienteId)
          .get();

      List<dynamic> profissionaisExistentes =
          pacienteDoc.data()?["profissionais"] ?? [];

      // 🔥 LIMITE DE 2 PROFISSIONAIS
      if (profissionaisExistentes.length >= 2 &&
          !profissionaisExistentes.contains(profissionalId)) {
        return "Este paciente já está vinculado ao máximo de 2 profissionais.";
      }

      // ======================================================
      // 3 ▸ Atualizar profissional → pacientes
      // ======================================================
      final profRef =
      _firestore.collection("profissional_pacientes").doc(profissionalId);

      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(profRef);

        if (!doc.exists) {
          tx.set(profRef, {
            "pacientes": [pacienteId]
          });
        } else {
          List<dynamic> lista = doc.data()?["pacientes"] ?? [];
          if (!lista.contains(pacienteId)) lista.add(pacienteId);
          tx.update(profRef, {"pacientes": lista});
        }
      });

      // ======================================================
      // 4 ▸ Atualizar paciente → profissionais
      // ======================================================
      final pacienteRef =
      _firestore.collection("paciente_profissionais").doc(pacienteId);

      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(pacienteRef);

        if (!doc.exists) {
          tx.set(pacienteRef, {
            "profissionais": [profissionalId]
          });
        } else {
          List<dynamic> lista = doc.data()?["profissionais"] ?? [];
          if (!lista.contains(profissionalId)) lista.add(profissionalId);
          tx.update(pacienteRef, {"profissionais": lista});
        }
      });

      // ======================================================
      // 5 ▸ 🔥 ATUALIZA O DOCUMENTO USERS/{pacienteId}
      // (É AQUI QUE FALTAVA!!!)
      // ======================================================
      await _firestore.collection("users").doc(pacienteId).set({
        "profissionaisVinculados":
        FieldValue.arrayUnion([profissionalId]),
      }, SetOptions(merge: true));

      return null; // ✔ sucesso
    } catch (e) {
      debugPrint("❌ Erro ao adicionar paciente: $e");
      return "Erro ao adicionar paciente.";
    }
  }
}
