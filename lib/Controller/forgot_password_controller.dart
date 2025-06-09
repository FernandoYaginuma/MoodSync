import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordController {
  final emailController = TextEditingController();

  Future<void> enviarEmailRecuperacao(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, digite seu e-mail.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Link para redefinição de senha enviado para o seu e-mail.')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String mensagem = 'Ocorreu um erro. Tente novamente.';
      if (e.code == 'user-not-found') {
        // Por segurança, não informamos que o usuário não foi encontrado.
        // A mensagem de sucesso é mostrada mesmo assim para evitar que alguém
        // descubra quais e-mails estão ou não cadastrados.
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Link para redefinição de senha enviado para o seu e-mail.')),
          );
          Navigator.pop(context);
        }
        return;
      } else if (e.code == 'invalid-email') {
        mensagem = 'O formato do e-mail é inválido.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
        );
      }
    }
  }

  void dispose() {
    emailController.dispose();
  }
}