import 'package:flutter/material.dart';

class CalendarController {
  late final ValueNotifier<DateTime> focusedDay;
  late final ValueNotifier<DateTime?> selectedDay;

  CalendarController({DateTime? initialDate}) {
    final safeDate = initialDate ?? DateTime.now();
    focusedDay = ValueNotifier(safeDate);
    selectedDay = ValueNotifier(safeDate);
  }

  void onDaySelected(
      BuildContext context, DateTime newSelectedDay, DateTime newFocusedDay) {
    // Normaliza a data (remove hora/minuto/segundo)
    final localDay = DateTime(
      newSelectedDay.year,
      newSelectedDay.month,
      newSelectedDay.day,
    );

    selectedDay.value = localDay;
    focusedDay.value = newFocusedDay;

    // Navega para a tela do dia selecionado
    Navigator.pushNamed(context, '/day', arguments: localDay);
  }

  void onPageChanged(DateTime newFocusedDay) {
    focusedDay.value = newFocusedDay;
  }

  void dispose() {
    focusedDay.dispose();
    selectedDay.dispose();
  }
}
