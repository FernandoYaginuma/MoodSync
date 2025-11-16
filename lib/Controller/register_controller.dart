import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterController {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final dataNascimentoController = TextEditingController();

  DateTime? dataNascimentoSelecionada;
  String? sexoSelecionado;

  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    dataNascimentoController.dispose();
  }

  Future<void> cadastrar(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'nome': nomeController.text.trim(),
          'email': emailController.text.trim(),
          'telefone': telefoneController.text.trim(),
          'dataNascimento': dataNascimentoSelecionada != null
              ? Timestamp.fromDate(dataNascimentoSelecionada!)
              : null,
          'sexo': sexoSelecionado ?? "Prefiro não informar",
          'role': 'paciente',
          'profissionaisVinculados': [], // ⭐ já começa vazio
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'O e-mail fornecido já está em uso.';
      } else {
        message = 'Ocorreu um erro. Tente novamente.';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }
}
