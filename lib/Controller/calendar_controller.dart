import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/Utils/emotions_utils.dart';
import 'package:android2/View/day_view.dart';

class CalendarController {
  final DateTime initialDate;

  CalendarController({required this.initialDate}) {
    selectedDay = ValueNotifier<DateTime?>(initialDate);
    focusedDay = ValueNotifier<DateTime>(initialDate);
  }

  // Dia selecionado / focado
  late ValueNotifier<DateTime?> selectedDay;
  late ValueNotifier<DateTime> focusedDay;

  /// Registros carregados do Firestore para o mês visível
  final Map<String, DayModel> _registros = {};

  // ======================================================
  //  CARREGAR REGISTROS DO MÊS ATUAL DO CALENDÁRIO
  // ======================================================
  Future<void> carregarRegistros() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final current = focusedDay.value;
    final firstDay = DateTime(current.year, current.month, 1);
    final lastDay = DateTime(current.year, current.month + 1, 0);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moodEntries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .get();

    _registros.clear();

    for (var doc in snapshot.docs) {
      final day = DayModel.fromFirestore(doc);
     _registros[doc.id] = day;
    }
  }

  // ======================================================
  //  DEFINIÇÃO DA EMOÇÃO DOMINANTE DO DIA
  // ======================================================
  String? emotionOfDay(DateTime date) {
    final key =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    if (!_registros.containsKey(key)) return null;

    final emotions = _registros[key]!.emotions;
    if (emotions.isEmpty) return null;

    bool hasNegative = false;
    bool hasSocial = false;
    bool hasPositive = false;

    for (final e in emotions) {
      final category = EmotionUtils.emotionCategory[e];

      if (category == EmotionUtils.negative) hasNegative = true;
      if (category == EmotionUtils.social) hasSocial = true;
      if (category == EmotionUtils.positive) hasPositive = true;
    }

    // Prioridade correta
    if (hasNegative) {
      return emotions.firstWhere(
            (e) => EmotionUtils.emotionCategory[e] == EmotionUtils.negative,
      );
    }

    if (hasSocial) {
      return emotions.firstWhere(
            (e) => EmotionUtils.emotionCategory[e] == EmotionUtils.social,
      );
    }

    if (hasPositive) {
      return emotions.firstWhere(
            (e) => EmotionUtils.emotionCategory[e] == EmotionUtils.positive,
      );
    }

    return null;
  }

  // ======================================================
  //  ABRIR O DIA E RECARREGAR QUANDO VOLTAR (HOT REFRESH)
  // ======================================================
  void onDaySelected(BuildContext context, DateTime selected, DateTime focused) async {
    selectedDay.value = selected;
    focusedDay.value = focused;

    // Abre a tela
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DayView(selectedDate: selected),
      ),
    );

    // Quando voltar → recarrega dados e força rebuild
    await carregarRegistros();
    selectedDay.notifyListeners();
    focusedDay.notifyListeners();
  }

  // ======================================================
  //  QUANDO TROCA DE MÊS → RECARREGA FIRESTORE
  // ======================================================
  void onPageChanged(DateTime focused) async {
    focusedDay.value = focused;
    await carregarRegistros();
    focusedDay.notifyListeners();
  }

  void dispose() {
    selectedDay.dispose();
    focusedDay.dispose();
  }
}
