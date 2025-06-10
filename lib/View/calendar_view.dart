import 'package:android2/Controller/calendar_controller.dart';
import 'package:android2/Controller/home_controller.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  final DateTime initialDate;

  const CalendarView({super.key, required this.initialDate});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late final CalendarController _calendarController;
  final HomeController _homeController = HomeController.instance;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController(initialDate: widget.initialDate);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  Color _getEmotionColor(String? emotion) {
    switch (emotion) {
      case 'Feliz':
        return Colors.green.shade200;
      case 'Agradecido':
        return Colors.yellow.shade200;
      case 'Confiante':
        return Colors.blue.shade200;
      case 'Triste':
        return Colors.grey.shade400;
      case 'Irritado':
        return Colors.red.shade300;
      case 'Ansioso':
        return Colors.purple.shade200;
      case 'Cansado':
        return Colors.brown.shade200;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendário de Humor"),
        backgroundColor: AppColors.blueLogo,
        foregroundColor: AppColors.blackBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<Map<String, DayModel>>(
          valueListenable: _homeController.diasRegistrados,
          builder: (context, dias, _) {
            return ValueListenableBuilder<DateTime?>(
              valueListenable: _calendarController.selectedDay,
              builder: (context, selectedDay, _) {
                return ValueListenableBuilder<DateTime>(
                  valueListenable: _calendarController.focusedDay,
                  builder: (context, focusedDay, _) {
                    return TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: focusedDay,
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: AppColors.blueLogo,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: AppColors.fontLogo,
                          shape: BoxShape.circle,
                        ),
                      ),
                      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                      onDaySelected: (newSelectedDay, newFocusedDay) {
                        _calendarController.onDaySelected(
                            context, newSelectedDay, newFocusedDay);
                      },
                      onPageChanged: (newFocusedDay) {
                        _calendarController.onPageChanged(newFocusedDay);
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final key =
                              "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                          final dayModel = dias[key];

                          if (dayModel != null) {
                            return Container(
                              margin: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: _getEmotionColor(dayModel.emotion),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}