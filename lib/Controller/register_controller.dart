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

  Future<void> cadastrar(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nome': nomeController.text.trim(),
        'email': emailController.text.trim(),
        'telefone': telefoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      switch (e.code) {
        case 'weak-password':
          mensagemErro = 'A senha fornecida é muito fraca.';
          break;
        case 'email-already-in-use':
          mensagemErro = 'Este e-mail já está em uso por outra conta.';
          break;
        case 'invalid-email':
          mensagemErro = 'O formato do e-mail é inválido.';
          break;
        default:
          mensagemErro = 'Ocorreu um erro de autenticação.';
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar dados: $e')),
        );
      }
    }
  }

  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
  }
}