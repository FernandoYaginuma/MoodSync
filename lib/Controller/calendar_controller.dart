import 'package:flutter/material.dart';

class CalendarController {
  late final ValueNotifier<DateTime> focusedDay;
  late final ValueNotifier<DateTime?> selectedDay;

  CalendarController({required DateTime initialDate}) {
    focusedDay = ValueNotifier(initialDate);
    selectedDay = ValueNotifier(initialDate);
  }

  void onDaySelected(
      BuildContext context, DateTime newSelectedDay, DateTime newFocusedDay) {
    final localDay =
        DateTime(newSelectedDay.year, newSelectedDay.month, newSelectedDay.day);

    selectedDay.value = localDay;
    focusedDay.value = newFocusedDay;

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