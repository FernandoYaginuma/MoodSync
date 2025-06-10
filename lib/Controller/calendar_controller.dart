import 'package:flutter/material.dart';
import 'package:android2/Controller/home_controller.dart';

class CalendarController {
  late final ValueNotifier<DateTime> focusedDay;
  late final ValueNotifier<DateTime?> selectedDay;

  final HomeController _homeController = HomeController.instance;

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

    Navigator.pushNamed(context, '/day', arguments: localDay).then((_) {
      _homeController.carregarDadosIniciais();
    });
  }

  void onPageChanged(DateTime newFocusedDay) {
    focusedDay.value = newFocusedDay;
  }

  void dispose() {
    focusedDay.dispose();
    selectedDay.dispose();
  }
}