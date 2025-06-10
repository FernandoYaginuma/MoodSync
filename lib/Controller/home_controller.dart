import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/Model/day_model.dart';

class HomeController {
  static final HomeController instance = HomeController._internal();
  HomeController._internal();
  factory HomeController() => instance;

  final ValueNotifier<String> nomeUsuario = ValueNotifier('Usuário');
  final ValueNotifier<Map<String, DayModel>> diasRegistrados =
      ValueNotifier({});

  Future<void> carregarDadosIniciais() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data()!.containsKey('nome')) {
      nomeUsuario.value = userDoc.data()!['nome'];
    }

    final moodEntriesSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moodEntries')
        .get();

    final Map<String, DayModel> loadedDays = {};
    for (var doc in moodEntriesSnapshot.docs) {
      final day = DayModel.fromJson(doc.data());
      loadedDays[day.formattedDate] = day;
    }
    diasRegistrados.value = loadedDays;
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}