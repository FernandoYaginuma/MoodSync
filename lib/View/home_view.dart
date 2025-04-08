import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../Controller/home_controller.dart';
import '../../Model/day_model.dart';
import '../../theme/colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = HomeController();

  @override
  void initState() {
    super.initState();
    controller.carregarNome();
    controller.carregarMockData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.blueLogo,
        foregroundColor: AppColors.blackBackground,
        title: const Text('MoodSync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<String>(
              valueListenable: controller.nomeUsuario,
              builder: (context, nome, _) {
                return Text(
                  'Olá, $nome!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackBackground,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.blueLogo,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                Navigator.pushNamed(
                  context,
                  '/calendar',
                  arguments: selectedDay,
                );
              },
              calendarFormat: CalendarFormat.week,
            ),
            const SizedBox(height: 16),
            const Text(
              'Registros Recentes:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blackBackground,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<Map<String, DayModel>>(
              valueListenable: controller.diasRegistrados,
              builder: (context, data, _) {
                if (data.isEmpty) {
                  return const Text('Nenhum registro encontrado.');
                }

                final diasOrdenados = data.values.toList()
                  ..sort((a, b) => b.date.compareTo(a.date));

                return Expanded(
                  child: ListView.builder(
                    itemCount: diasOrdenados.length,
                    itemBuilder: (context, index) {
                      final day = diasOrdenados[index];
                      final formattedDate =
                          "${day.date.day.toString().padLeft(2, '0')}/${day.date.month.toString().padLeft(2, '0')}/${day.date.year}";

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.emoji_emotions, color: AppColors.blueLogo),
                          title: Text('Emoção: ${day.emotion}'),
                          subtitle: Text(day.note),
                          trailing: Text(formattedDate),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
