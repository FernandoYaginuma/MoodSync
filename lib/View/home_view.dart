import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Controller/home_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = HomeController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    controller.carregarNome();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void irParaCalendarioCompleto() {
    Navigator.pushNamed(context, '/calendar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        backgroundColor: AppColors.blueLogo,
        title: const Text('MoodSync'),
        actions: [
          IconButton(
            onPressed: () => controller.logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ValueListenableBuilder<String>(
              valueListenable: controller.nomeUsuario,
              builder: (context, nome, _) {
                return Text(
                  'Bem-vindo, $nome!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                headerVisible: true,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.blueLogo,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mês',
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: irParaCalendarioCompleto,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Ver Calendário Completo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLogo,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
