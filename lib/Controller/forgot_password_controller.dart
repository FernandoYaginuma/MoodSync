import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordController {
  final emailController = TextEditingController();
  final novaSenhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  Future<bool> verificarEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final emailSalvo = prefs.getString('email');
    return emailSalvo == email;
  }

  Future<void> redefinirSenha(BuildContext context) async {
    final novaSenha = novaSenhaController.text;
    final confirmar = confirmarSenhaController.text;

    if (novaSenha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha muito curta (mín. 6 caracteres)')),
      );
      return;
    }

    if (novaSenha != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não coincidem')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('senha', novaSenha);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  void dispose() {
    emailController.dispose();
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
  }
}
