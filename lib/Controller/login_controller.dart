import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> fazerLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      switch (e.code) {
        case 'user-not-found':
          mensagemErro = 'Nenhum usuário encontrado com este e-mail.';
          break;
        case 'wrong-password':
          mensagemErro = 'Senha incorreta. Por favor, tente novamente.';
          break;
        case 'invalid-email':
          mensagemErro = 'O formato do e-mail é inválido.';
          break;
        default:
          mensagemErro = 'Ocorreu um erro. Tente novamente mais tarde.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErro)),
        );
      }
    }
  }

  void dispose() {
    emailController.dispose();
    senhaController.dispose();
  }
}