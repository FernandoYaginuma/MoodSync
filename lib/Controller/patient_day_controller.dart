import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/day_model.dart';
import '../Model/activity_model.dart';

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

  // 🔵 Busca as atividades (nome/ícone) a partir dos IDs salvos no day.activityIds
  // (Firestore whereIn tem limite de 10, então fazemos em lotes)
  Future<List<ActivityModel>> carregarAtividadesPorIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final List<ActivityModel> found = [];

    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, (i + 10 > ids.length) ? ids.length : i + 10);

      final snap = await _firestore
          .collection('activities')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snap.docs) {
        found.add(ActivityModel.fromFirestore(doc.data(), doc.id));
      }
    }

    // Mantém a ordem original do "ids"
    final map = {for (final a in found) a.id: a};
    return ids.where(map.containsKey).map((id) => map[id]!).toList();
  }
}
