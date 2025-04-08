import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/day_model.dart';

class HomeController {
  static final HomeController instance = HomeController._internal();
  HomeController._internal();
  factory HomeController() => instance;

  final ValueNotifier<String> nomeUsuario = ValueNotifier('Usuário');
  final ValueNotifier<Map<String, DayModel>> diasRegistrados = ValueNotifier({});

  Future<void> carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString('nome') ?? 'Usuário';
    nomeUsuario.value = nome;
  }

  void carregarMockData() {
    diasRegistrados.value = {
      '2025-04-06': DayModel(
        date: DateTime(2025, 4, 6),
        emotion: 'Feliz',
        note: 'Dia produtivo e animado!',
      ),
      '2025-04-05': DayModel(
        date: DateTime(2025, 4, 5),
        emotion: 'Cansado',
        note: 'Trabalhei muito, estou exausto.',
      ),
    };
  }

  void adicionarDia(DayModel dia) {
    final key = "${dia.date.year}-${dia.date.month.toString().padLeft(2, '0')}-${dia.date.day.toString().padLeft(2, '0')}";
    final novoMapa = Map<String, DayModel>.from(diasRegistrados.value);
    novoMapa[key] = dia;
    diasRegistrados.value = novoMapa;
  }

  void logout(BuildContext context) {
  Navigator.pushReplacementNamed(context, '/');
}

}
