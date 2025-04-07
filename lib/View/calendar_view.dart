import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendário")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              selectedDayPredicate: (_) => false,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                Navigator.pushNamed(
                  context,
                  '/day',
                  arguments: selectedDay,
                );
              },
            ),
            const SizedBox(height: 20),

            if (_selectedDay != null) ...[
              Text(
                "Selecionado: ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/professional');
                },
                icon: const Icon(Icons.person_add_alt_1, color: Colors.blue),
                label: const Text(
                  "Adicionar profissional",
                  style: TextStyle(color: Colors.blue),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
