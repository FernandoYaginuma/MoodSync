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

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();

    final safeInitialDate = _dateOnly(widget.initialDate ?? DateTime.now());
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
              final d = _dateOnly(selectedDay ?? DateTime.now());
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
          final safeFocused = _dateOnly(focusedDay);
          final safeSelected =
              _dateOnly(controller.selectedDay.value ?? safeFocused);

          return TableCalendar(
            locale: 'pt_BR',

            // ✅ NÃO use UTC aqui (isso é o que costuma causar "dia anterior")
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),

            focusedDay: safeFocused,

            selectedDayPredicate: (day) =>
                isSameDay(safeSelected, _dateOnly(day)),

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
                // ✅ normaliza também no marker
                final emotion = controller.emotionOfDay(_dateOnly(date));
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

            onDaySelected: (selectedDay, focusedDay) async {
              // ✅ sempre salva no controller sem hora
              final selected = _dateOnly(selectedDay);
              final focused = _dateOnly(focusedDay);

              controller.selectedDay.value = selected;
              controller.focusedDay.value = focused;

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  // ✅ passa para o DayView sem hora (evita docId errado)
                  builder: (_) => DayView(selectedDate: selected),
                ),
              );

              if (result == true) {
                await controller.carregarRegistros();
                if (mounted) setState(() {});
              }
            },

            onPageChanged: (focusedDay) {
              final focused = _dateOnly(focusedDay);
              controller.onPageChanged(focused);
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
