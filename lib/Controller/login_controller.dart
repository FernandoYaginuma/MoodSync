import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final formKey = GlobalKey<FormState>();

  final usuarioOuEmailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> fazerLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final input = usuarioOuEmailController.text.trim();
    final senhaDigitada = senhaController.text;

    final prefs = await SharedPreferences.getInstance();
    final emailSalvo = prefs.getString('email');
    final usuarioSalvo = prefs.getString('nome');
    final senhaSalva = prefs.getString('senha');

    final loginCorreto = (input == emailSalvo || input == usuarioSalvo) && senhaDigitada == senhaSalva;

    if (loginCorreto) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário ou senha inválidos')),
        );
      }
    }
  }

  void dispose() {
    usuarioOuEmailController.dispose();
    senhaController.dispose();
  }
}
