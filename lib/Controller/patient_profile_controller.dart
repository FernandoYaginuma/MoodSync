import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientProfileController {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final dataNascController = TextEditingController();

  String sexoSelecionado = "Prefiro não informar";

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ============================================================
  // 🔵 CARREGAR DADOS DO PACIENTE
  // ============================================================
  Future<void> carregarDados() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection("users").doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;

        nomeController.text = data["nome"] ?? "";
        emailController.text = data["email"] ?? "";
        telefoneController.text = data["telefone"] ?? "";
        dataNascController.text = data["dataNascimento"] ?? "";

        sexoSelecionado = data["sexo"] ?? "Prefiro não informar";
      }
    } catch (e) {
      print("Erro ao carregar dados do paciente: $e");
    }
  }

  // ============================================================
  // 🔵 SALVAR ALTERAÇÕES
  // ============================================================
  Future<String?> salvarAlteracoes() async {
    final user = _auth.currentUser;
    if (user == null) return "Usuário não autenticado.";

    try {
      await _firestore.collection("users").doc(user.uid).update({
        "nome": nomeController.text.trim(),
        "telefone": telefoneController.text.trim(),
        "dataNascimento": dataNascController.text.trim(),
        "sexo": sexoSelecionado,
      });

      return null; // sucesso
    } catch (e) {
      return "Erro ao salvar: $e";
    }
  }

  // ============================================================
  // 🔵 LIMPAR CONTROLLERS
  // ============================================================
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    dataNascController.dispose();
  }
}
