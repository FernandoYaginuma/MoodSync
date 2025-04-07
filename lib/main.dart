import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:android2/View/calendar_view.dart';
import 'package:android2/View/day_view.dart';
import 'package:android2/View/professional_view.dart'; // NOVO: importar a tela Professional

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Diário de Emoções',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const CalendarView(),
        '/day': (context) {
          final selectedDate = ModalRoute.of(context)!.settings.arguments as DateTime;
          return DayView(selectedDate: selectedDate);
        },
        '/professional': (context) => const ProfessionalView(), // NOVO
      },
    );
  }
}
