import 'package:flutter/material.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/Controller/patient_calendar_controller.dart';
import 'package:android2/theme/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:android2/View/patient_day_view.dart';
import 'package:android2/View/patient_mural_view.dart';

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

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    controller = PatientCalendarController(widget.pacienteId);
    _focusedDay = _dateOnly(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Registros de ${widget.pacienteNome}"),
        backgroundColor: AppColors.blueLogo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                // ✅ NÃO use UTC aqui (evita "dia anterior" por fuso)
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime(2030, 12, 31),

                focusedDay: _dateOnly(_focusedDay),

                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),

                onDaySelected: (selected, focused) {
                  final selectedLocal = _dateOnly(selected);
                  final focusedLocal = _dateOnly(focused);

                  setState(() {
                    _focusedDay = focusedLocal;
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ✅ passa SEM hora pro PatientDayView
                      builder: (_) => PatientDayView(
                        pacienteId: widget.pacienteId,
                        date: selectedLocal,
                      ),
                    ),
                  );
                },

                selectedDayPredicate: (_) => false,

                onPageChanged: (focused) {
                  setState(() {
                    _focusedDay = _dateOnly(focused);
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: const Text(
                  "Ver Mural do Profissional",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueLogo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientMuralView(
                        pacienteId: widget.pacienteId,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: StreamBuilder<Map<String, DayModel>>(
                stream: controller.getRegistros(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dias = snapshot.data!;
                  if (dias.isEmpty) {
                    return const Center(
                      child: Text(
                        "Sem registros ainda.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final lista = dias.values.toList()
                    ..sort((a, b) => b.date.compareTo(a.date));

                  return ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final day = lista[i];

                      final d = _dateOnly(day.date);
                      final date =
                          "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

                      final emotionsText = day.emotions.isEmpty
                          ? "Sem sentimentos"
                          : day.emotions.join(', ');

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          title: Text(
                            emotionsText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            day.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientDayView(
                                  pacienteId: widget.pacienteId,
                                  // ✅ também passa SEM hora
                                  date: _dateOnly(day.date),
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
