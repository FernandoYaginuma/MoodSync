import 'package:flutter/material.dart';

class LoginController {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  void login(BuildContext context) {
    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }
    Navigator.pushNamed(context, '/home');
  }
}
