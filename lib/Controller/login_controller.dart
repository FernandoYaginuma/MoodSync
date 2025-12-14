import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/View/home_view.dart';
import 'package:android2/View/professional_home_view.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fazerLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      // ============================================================
      // 🔐 LOGIN
      // ============================================================
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw FirebaseAuthException(code: "user-null");

      // ============================================================
      // 🔍 IDENTIFICA TIPO DE USUÁRIO
      // ============================================================
      final profissionalSnap =
      await _firestore.collection('professionals').doc(user.uid).get();

      final pacienteSnap =
      await _firestore.collection('users').doc(user.uid).get();

      if (!profissionalSnap.exists && !pacienteSnap.exists) {
        throw Exception("Usuário não encontrado no banco de dados.");
      }

      String nome;
      bool isProfissional;

      if (profissionalSnap.exists) {
        final data = profissionalSnap.data()!;
        nome = data['nome'] ?? 'Profissional';
        isProfissional = true;
      } else {
        final data = pacienteSnap.data()!;
        nome = data['nome'] ?? 'Paciente';
        isProfissional = false;
      }

      // ============================================================
      // 🚀 REDIRECIONAMENTO
      // ============================================================
      if (context.mounted) {
        if (isProfissional) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProfessionalHomeView(
                profissionalId: user.uid,
                profissionalNome: nome,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeView(),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      switch (e.code) {
        case 'user-not-found':
          mensagemErro = 'Nenhum usuário encontrado com este e-mail.';
          break;
        case 'wrong-password':
          mensagemErro = 'Senha incorreta.';
          break;
        case 'invalid-email':
          mensagemErro = 'O formato do e-mail é inválido.';
          break;
        default:
          mensagemErro = 'Erro ao fazer login.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(mensagemErro)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    }
  }

  // ============================================================
  // 🔔 VERIFICA VINCULAÇÕES PENDENTES
  // ============================================================
  Future<void> _verificarVinculacoesPendentes(
      BuildContext context,
      String email,
      String pacienteId,
      ) async {
    final snap = await _firestore
        .collection('vinculacoes')
        .where('pacienteEmail', isEqualTo: email)
        .where('status', isEqualTo: 'pendente')
        .get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final profissionalNome = data['profissionalNome'] ?? 'Profissional';

      final aceitar = await _mostrarDialogConsentimento(
        context,
        profissionalNome,
      );

      if (aceitar == null) return;

      if (aceitar) {
        await _aceitarVinculacao(doc.id, data['profissionalId'], pacienteId);
      } else {
        await _recusarVinculacao(doc.id);
      }
    }
  }

  // ============================================================
  // 🪟 DIALOG DE CONSENTIMENTO
  // ============================================================
  Future<bool?> _mostrarDialogConsentimento(
      BuildContext context,
      String profissionalNome,
      ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Solicitação de vínculo"),
        content: Text(
          "$profissionalNome deseja se vincular a você.",
        ),
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

  // ============================================================
  // ✅ ACEITAR VINCULAÇÃO (CRIA VÍNCULO DEFINITIVO)
  // ============================================================
  Future<void> _aceitarVinculacao(
      String docId,
      String profissionalId,
      String pacienteId,
      ) async {
    // Atualiza status
    await _firestore.collection('vinculacoes').doc(docId).update({
      'status': 'aceito',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // profissional → pacientes
    await _firestore
        .collection('profissional_pacientes')
        .doc(profissionalId)
        .set({
      'pacientes': FieldValue.arrayUnion([pacienteId])
    }, SetOptions(merge: true));

    // paciente → profissionais
    await _firestore
        .collection('paciente_profissionais')
        .doc(pacienteId)
        .set({
      'profissionais': FieldValue.arrayUnion([profissionalId])
    }, SetOptions(merge: true));

    // users
    await _firestore.collection('users').doc(pacienteId).set({
      'profissionaisVinculados': FieldValue.arrayUnion([profissionalId]),
    }, SetOptions(merge: true));
  }

  // ============================================================
  // ❌ RECUSAR VINCULAÇÃO
  // ============================================================
  Future<void> _recusarVinculacao(String docId) async {
    await _firestore.collection('vinculacoes').doc(docId).update({
      'status': 'recusado',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  void dispose() {
    emailController.dispose();
    senhaController.dispose();
  }
}
