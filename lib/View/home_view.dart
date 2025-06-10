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
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    controller.carregarDadosUsuario();
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
            Expanded(
              child: StreamBuilder<Map<String, DayModel>>(
                stream: controller.getRegistrosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Erro ao carregar registros."));
                  }

                  final data = snapshot.data ?? {};

                  final diasOrdenados = data.values.toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

                  return Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
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
                          final localDay = DateTime(selectedDay.year,
                              selectedDay.month, selectedDay.day);
                          Navigator.pushNamed(context, '/calendar',
                              arguments: localDay);
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        eventLoader: (day) {
                          final key =
                              "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                          return data.containsKey(key) ? [data[key]] : [];
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isNotEmpty) {
                              return Positioned(
                                right: 1,
                                bottom: 1,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.blueLogo,
                                  ),
                                  width: 7.0,
                                  height: 7.0,
                                ),
                              );
                            }
                            return null;
                          },
                        ),
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
                      if (diasOrdenados.isEmpty)
                        const Center(child: Text('Nenhum registro encontrado.'))
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: diasOrdenados.length,
                            itemBuilder: (context, index) {
                              final day = diasOrdenados[index];
                              final formattedDate =
                                  "${day.date.day.toString().padLeft(2, '0')}/${day.date.month.toString().padLeft(2, '0')}/${day.date.year}";

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(
                                      Icons.sentiment_very_satisfied,
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
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}