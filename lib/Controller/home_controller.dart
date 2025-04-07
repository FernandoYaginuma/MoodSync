import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController {
  final ValueNotifier<String> nomeUsuario = ValueNotifier<String>('Usuário');

  Future<void> carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome') ?? 'Usuário';
    nomeUsuario.value = nome;
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void dispose() {
    nomeUsuario.dispose();
  }
}
