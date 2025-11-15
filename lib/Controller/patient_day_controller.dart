import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/day_model.dart';

class PatientDayController {
  final String pacienteId;
  final DateTime data;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PatientDayController({
    required this.pacienteId,
    required this.data,
  });

  // Carrega o DayModel do paciente para a data especificada
  Future<DayModel?> carregarDia() async {
    final docId =
        "${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}";

    final snap = await _firestore
        .collection("users")
        .doc(pacienteId)
        .collection("moodEntries")
        .doc(docId)
        .get();

    if (!snap.exists) return null;

    return DayModel.fromFirestore(snap);
  }
}
