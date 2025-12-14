import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'package:android2/View/calendar_view.dart';
import 'package:android2/View/day_view.dart';
import 'package:android2/View/login_view.dart';
import 'package:android2/View/register_view.dart';
import 'package:android2/View/forgot_password_view.dart';
import 'package:android2/View/about_view.dart';
import 'package:android2/View/home_view.dart';

// ============================================================
// ✅ Emulator via --dart-define
// Exemplo (Android físico):
// flutter run --dart-define=USE_FIREBASE_EMULATORS=true --dart-define=EMULATOR_HOST=192.168.0.15
// ============================================================
const bool useEmulators =
bool.fromEnvironment('USE_FIREBASE_EMULATORS', defaultValue: false);

const String emulatorHost =
String.fromEnvironment('EMULATOR_HOST', defaultValue: '10.0.2.2');

const int authEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode && useEmulators) {
    debugPrint("🔥 Usando Firebase Emulator em $emulatorHost");
    FirebaseAuth.instance.useAuthEmulator(emulatorHost, authEmulatorPort);
    FirebaseFirestore.instance.useFirestoreEmulator(
      emulatorHost,
      firestoreEmulatorPort,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoodSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', ''),
      ],
      initialRoute: '/',
      routes: {
        // ✅ mantém '/' como login
        '/': (context) => LoginHomeView(),

        // ✅ alias para evitar crash quando alguém navega pra '/login'
        '/login': (context) => LoginHomeView(),

        '/register': (context) => const RegisterView(),
        '/forgot-password': (context) => const ForgotPasswordView(),
        '/about': (context) => AboutView(),
        '/calendar': (context) {
          final selectedDate =
          ModalRoute.of(context)!.settings.arguments as DateTime;
          return CalendarView(initialDate: selectedDate);
        },
        '/day': (context) {
          final selectedDate =
          ModalRoute.of(context)!.settings.arguments as DateTime;
          return DayView(selectedDate: selectedDate);
        },
        '/home': (context) => const HomeView(),
      },
    );
  }
}
