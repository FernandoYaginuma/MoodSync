import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android2/Controller/home_controller.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/theme/colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = HomeController.instance;

  @override
  void initState() {
    super.initState();
    controller.carregarDadosIniciais();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.blueLogo,
        foregroundColor: AppColors.fontLogo,
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
              calendarFormat: CalendarFormat.week,
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
                final localDay =
                    DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                Navigator.pushNamed(context, '/calendar', arguments: localDay)
                    .then((_) {
                  controller.carregarDadosIniciais();
                });
              },
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
                  return const Expanded(
                    child: Center(child: Text('Nenhum registro encontrado.')),
                  );
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
                          leading: const Icon(Icons.sentiment_very_satisfied,
                              color: AppColors.blueLogo),
                          title: Text(day.emotion ?? 'Sem sentimento'),
                          subtitle: Text(
                            day.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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