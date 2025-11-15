import 'package:flutter/material.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/Controller/patient_calendar_controller.dart';
import 'package:android2/theme/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android2/View/patient_day_view.dart';

class PatientCalendarView extends StatefulWidget {
  final String pacienteId;
  final String pacienteNome;

  const PatientCalendarView({
    super.key,
    required this.pacienteId,
    required this.pacienteNome,
  });

  @override
  State<PatientCalendarView> createState() => _PatientCalendarViewState();
}

class _PatientCalendarViewState extends State<PatientCalendarView> {
  late PatientCalendarController controller;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    controller = PatientCalendarController(widget.pacienteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text("Registros de ${widget.pacienteNome}"),
        backgroundColor: AppColors.blueLogo,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CALENDÁRIO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),

                // 🔵 ABRE A TELA DE DETALHES DO DIA
                onDaySelected: (selected, focused) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDayView(
                        pacienteId: widget.pacienteId,
                        date: selected,
                      ),
                    ),
                  );
                },

                onPageChanged: (focused) => _focusedDay = focused,
              ),
            ),

            const SizedBox(height: 20),

            // LISTA DE REGISTROS
            Expanded(
              child: StreamBuilder<Map<String, DayModel>>(
                stream: controller.getRegistros(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dias = snapshot.data!;
                  if (dias.isEmpty) {
                    return const Center(child: Text("Sem registros ainda."));
                  }

                  final lista = dias.values.toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

                  return ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final day = lista[i];
                      final date =
                          "${day.date.day.toString().padLeft(2, '0')}/${day.date.month}/${day.date.year}";

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(day.emotion ?? "Sem sentimento"),
                          subtitle: Text(day.note),
                          trailing: Text(date),

                          // 🔵 AQUI TORNA O CARD CLICÁVEL
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientDayView(
                                  pacienteId: widget.pacienteId,
                                  date: day.date,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
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
