import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:android2/Model/patient_model.dart';

class ProfessionalHomeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista de pacientes vinculados
  final ValueNotifier<List<PatientModel>> pacientes = ValueNotifier([]);

  // Busca pacientes do profissional logado
  Future<void> carregarPacientes(String profissionalId) async {
    try {
      final doc = await _firestore
          .collection('profissional_pacientes')
          .doc(profissionalId)
          .get();

      if (doc.exists) {
        List<dynamic> ids = doc.data()?['pacientes'] ?? [];
        if (ids.isEmpty) {
          pacientes.value = [];
          return;
        }

        // Busca informações dos pacientes
        final snapshots = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: ids)
            .get();

        pacientes.value = snapshots.docs
            .map((d) => PatientModel.fromJson(d.id, d.data()))
            .toList();
      } else {
        pacientes.value = [];
      }
    } catch (e) {
      debugPrint("Erro ao carregar pacientes: $e");
    }
  }

  // Adiciona novo paciente (por e-mail)
  Future<String?> adicionarPaciente(String profissionalId, String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'paciente')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return "Paciente não encontrado.";
      }

      final pacienteId = snapshot.docs.first.id;

      final ref = _firestore
          .collection('profissional_pacientes')
          .doc(profissionalId);

      await _firestore.runTransaction((tx) async {
        final doc = await tx.get(ref);
        if (doc.exists) {
          List<dynamic> pacientes = doc.data()?['pacientes'] ?? [];
          if (!pacientes.contains(pacienteId)) {
            pacientes.add(pacienteId);
            tx.update(ref, {'pacientes': pacientes});
          }
        } else {
          tx.set(ref, {'pacientes': [pacienteId]});
        }
      });

      return null; // sucesso
    } catch (e) {
      debugPrint("Erro ao adicionar paciente: $e");
      return "Erro ao adicionar paciente.";
    }
  }
}
