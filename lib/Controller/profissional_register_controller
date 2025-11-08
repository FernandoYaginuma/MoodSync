import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfessionalRegisterController {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final telefoneController = TextEditingController();
  final especialidadeController = TextEditingController();
  final registroProfissionalController = TextEditingController();
  final descricaoController = TextEditingController();

  Future<void> cadastrar(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final user = cred.user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('profissional')
            .doc(user.uid)
            .set({
          'nome': nomeController.text.trim(),
          'email': emailController.text.trim(),
          'telefone': telefoneController.text.trim(),
          'especialidade': especialidadeController.text.trim(),
          'registroProfissional': registroProfissionalController.text.trim(),
          'descricao': descricaoController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro de profissional realizado!')),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'email-already-in-use'
          ? 'E-mail já está em uso.'
          : e.code == 'weak-password'
              ? 'Senha muito fraca.'
              : 'Erro ao cadastrar. Tente novamente.';
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    telefoneController.dispose();
    especialidadeController.dispose();
    registroProfissionalController.dispose();
    descricaoController.dispose();
  }
}
