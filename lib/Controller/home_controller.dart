import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/Model/day_model.dart';

class HomeController {
  static final HomeController instance = HomeController._internal();
  HomeController._internal();
  factory HomeController() => instance;

  final ValueNotifier<String> nomeUsuario = ValueNotifier('Usuário');

  Future<void> carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data()!.containsKey('nome')) {
      nomeUsuario.value = userDoc.data()!['nome'];
    }
  }

  Stream<Map<String, DayModel>> getRegistrosStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value({});
    }

    final snapshots = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moodEntries')
        .snapshots();

    return snapshots.map((querySnapshot) {
      final Map<String, DayModel> days = {};
      for (var doc in querySnapshot.docs) {
        final day = DayModel.fromJson(doc.data());
        days[day.formattedDate] = day;
      }
      return days;
    });
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
}