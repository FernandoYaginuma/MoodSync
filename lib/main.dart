import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

import 'package:android2/View/calendar_view.dart';
import 'package:android2/View/day_view.dart';
import 'package:android2/View/professional_view.dart';
import 'package:android2/View/login_view.dart';
import 'package:android2/View/register_view.dart';
import 'package:android2/View/forgot_password_view.dart';
import 'package:android2/View/about_view.dart';
import 'package:android2/View/home_view.dart';

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
      title: 'MoodSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginHomeView(),
        '/register': (context) => const RegisterView(),
        '/forgot-password': (context) => const ForgotPasswordView(),
        '/about': (context) => AboutView(),
        '/calendar': (context) {
          final SelectedDate = ModalRoute.of(context)!.settings.arguments as DateTime;
          return CalendarView(initialDate: SelectedDate);
        },
        '/day': (context) {
          final selectedDate = ModalRoute.of(context)!.settings.arguments as DateTime;
          return DayView(selectedDate: selectedDate);
        },
        '/professional': (context) => const ProfessionalView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}
