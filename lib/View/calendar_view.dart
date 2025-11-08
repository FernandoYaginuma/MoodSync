import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Controller/calendar_controller.dart';

class CalendarView extends StatefulWidget {
  final DateTime? initialDate;

  const CalendarView({super.key, this.initialDate});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late CalendarController controller;

  @override
  void initState() {
    super.initState();
    final safeInitialDate = widget.initialDate ?? DateTime.now();
    controller = CalendarController(initialDate: safeInitialDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFB3E5FC),
                Color(0xFFE1F5FE),
              ],
            ),
          ),
        ),
        title: const Text(
          "Calendário de Humor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
        foregroundColor: AppColors.fontLogo,
        backgroundColor: Colors.transparent,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.blueLogo.withOpacity(0.25),
            Colors.white,
          ],
        ),
      ),
      child: _content(),
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _calendarCard(),
          const SizedBox(height: 24),
          ValueListenableBuilder<DateTime?>(
            valueListenable: controller.selectedDay,
            builder: (context, selectedDay, _) {
              final safeSelected = selectedDay ?? DateTime.now();
              return Text(
                'Dia selecionado: ${safeSelected.day.toString().padLeft(2, '0')}/${safeSelected.month.toString().padLeft(2, '0')}/${safeSelected.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackBackground,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 45,
            width: 240,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/professional'),
              icon: const Icon(Icons.group_add_outlined),
              label: const Text('Adicionar profissional'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLogo,
                foregroundColor: AppColors.fontLogo,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calendarCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ValueListenableBuilder<DateTime>(
        valueListenable: controller.focusedDay,
        builder: (context, focusedDay, _) {
          final safeFocused = focusedDay ?? DateTime.now();
          final safeSelected = controller.selectedDay.value ?? safeFocused;

          return TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: safeFocused,
            selectedDayPredicate: (day) => isSameDay(safeSelected, day),
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
            onDaySelected: (selectedDay, focusedDay) {
              controller.onDaySelected(context, selectedDay, focusedDay);
              setState(() {});
            },
            onPageChanged: controller.onPageChanged,
          );
        },
      ),
    );
  }
}
