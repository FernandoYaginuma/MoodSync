import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final especialidadeController = TextEditingController();
  final registroProfissionalController = TextEditingController();
  final descricaoController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> carregarDados() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection("professionals").doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      nomeController.text = data["nome"] ?? "";
      emailController.text = data["email"] ?? "";
      telefoneController.text = data["telefone"] ?? "";
      especialidadeController.text = data["especialidade"] ?? "";
      registroProfissionalController.text = data["registroProfissional"] ?? "";
      descricaoController.text = data["descricao"] ?? "";
    }
  }

  Future<String?> salvarAlteracoes() async {
    final user = _auth.currentUser;
    if (user == null) return "Usuário não autenticado.";

    try {
      await _firestore.collection("professionals").doc(user.uid).update({
        "nome": nomeController.text.trim(),
        "telefone": telefoneController.text.trim(),
        "especialidade": especialidadeController.text.trim(),
        "registroProfissional":
        registroProfissionalController.text.trim(),
        "descricao": descricaoController.text.trim(),
      });

      return null;
    } catch (e) {
      return "Erro ao salvar: $e";
    }
  }

  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    especialidadeController.dispose();
    registroProfissionalController.dispose();
    descricaoController.dispose();
  }
}
