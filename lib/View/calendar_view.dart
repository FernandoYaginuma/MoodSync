import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Controller/calendar_controller.dart';
import 'package:android2/Utils/emotions_utils.dart';
import 'package:android2/View/day_view.dart';

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

    controller.carregarRegistros().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

          /// -------- DIA SELECIONADO --------
          ValueListenableBuilder<DateTime?>(
            valueListenable: controller.selectedDay,
            builder: (context, selectedDay, _) {
              final d = selectedDay ?? DateTime.now();
              return Text(
                'Dia selecionado: ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackBackground,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔷 CARTÃO DO CALENDÁRIO
  // ============================================================
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
          final safeFocused = focusedDay;
          final safeSelected = controller.selectedDay.value ?? safeFocused;

          return TableCalendar(
            locale: 'pt_BR', // 🔵 AGORA O CALENDÁRIO FICA EM PORTUGUÊS

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

            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                final emotion = controller.emotionOfDay(date);
                if (emotion == null) return const SizedBox();

                final color = EmotionUtils.emotionColor(emotion);

                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),

            // Quando o usuário escolher um dia
            onDaySelected: (selectedDay, focusedDay) async {
              controller.selectedDay.value = selectedDay;
              controller.focusedDay.value = focusedDay;

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => DayView(selectedDate: selectedDay),
                ),
              );

              if (result == true) {
                await controller.carregarRegistros();
                if (mounted) setState(() {});
              }
            },

            onPageChanged: (focusedDay) {
              controller.onPageChanged(focusedDay);
              controller.carregarRegistros().then((_) {
                if (mounted) setState(() {});
              });
            },
          );
        },
      ),
    );
  }
}
