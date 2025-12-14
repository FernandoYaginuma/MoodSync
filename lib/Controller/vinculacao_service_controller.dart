import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VinculacaoServiceController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> verificarVinculacoesPendentes(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    final pacienteId = user?.uid;

    if (email == null || pacienteId == null) return;

    final snap = await _firestore
        .collection('vinculacoes')
        .where('pacienteEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pendente')
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final profissionalNome = data['profissionalNome'] ?? 'Profissional';
      final profissionalId = data['profissionalId'];

      final aceitar = await _mostrarDialogConsentimento(
        context,
        profissionalNome,
      );

      if (aceitar == null) return;

      if (aceitar) {
        await _aceitarVinculacao(doc.id, profissionalId, pacienteId);
      } else {
        await _recusarVinculacao(doc.id);
      }
    }
  }

  Future<bool?> _mostrarDialogConsentimento(
    BuildContext context,
    String profissionalNome,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Solicitação de vínculo"),
        content: Text("$profissionalNome deseja se vincular a você."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Recusar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Aceitar"),
          ),
        ],
      ),
    );
  }

  Future<void> _aceitarVinculacao(
    String docId,
    String profissionalId,
    String pacienteId,
  ) async {
    await _firestore.collection('vinculacoes').doc(docId).update({
      'status': 'aceito',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('profissional_pacientes')
        .doc(profissionalId)
        .set({
      'pacientes': FieldValue.arrayUnion([pacienteId])
    }, SetOptions(merge: true));

    await _firestore
        .collection('paciente_profissionais')
        .doc(pacienteId)
        .set({
      'profissionais': FieldValue.arrayUnion([profissionalId])
    }, SetOptions(merge: true));

    await _firestore.collection('users').doc(pacienteId).set({
      'profissionaisVinculados': FieldValue.arrayUnion([profissionalId]),
    }, SetOptions(merge: true));
  }

  Future<void> _recusarVinculacao(String docId) async {
    await _firestore.collection('vinculacoes').doc(docId).update({
      'status': 'recusado',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }
}
