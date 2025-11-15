import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Model/day_model.dart';
import '../View/patient_day_view.dart';

class PatientCalendarController {
  final String pacienteId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PatientCalendarController(this.pacienteId);

  // ------------------------------------------------------------
  // 🔵 Ler todos os registros (moodEntries)
  // ------------------------------------------------------------
  Stream<Map<String, DayModel>> getRegistros() {
    return _firestore
        .collection("users")
        .doc(pacienteId)
        .collection("moodEntries")
        .snapshots()
        .map((snap) {
      return {
        for (var doc in snap.docs)
          doc.id: DayModel.fromFirestore(doc)
      };
    });
  }

  // ------------------------------------------------------------
  // 🔵 Abrir tela do dia clicado
  // ------------------------------------------------------------
  void openDay(DateTime date, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDayView(
          pacienteId: pacienteId,
          date: date,
        ),
      ),
    );
  }
}
