import 'package:flutter/material.dart';
import '../../View/day_view.dart'; // Caminho correto para sua View

class CalendarController {
  void onDaySelected(BuildContext context, DateTime selectedDay, DateTime focusedDay, Function setStateCallback) {
    setStateCallback(selectedDay, focusedDay);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DayView(selectedDate: selectedDay),
      ),
    );
  }
}
