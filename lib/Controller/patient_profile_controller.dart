import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:android2/Model/professional_model.dart';

class PatientProfileController extends ChangeNotifier {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final telefoneController = TextEditingController();
  final dataNascController = TextEditingController();

  String sexoSelecionado = "Prefiro não informar";

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Lista de profissionais carregados
  List<ProfessionalModel> profissionaisVinculados = [];

  // ============================================================
  // 🔧 Utils de Data
  // ============================================================
  String _fmtDate(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  DateTime? _parseBR(String s) {
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  // ============================================================
  // 🔵 CARREGAR PERFIL + PROFISSIONAIS
  // ============================================================
  Future<void> carregarDados() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection("users").doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;

        nomeController.text = data["nome"] ?? "";
        emailController.text = data["email"] ?? "";
        telefoneController.text = data["telefone"] ?? "";

        // ✅ dataNascimento pode vir como Timestamp (correto) ou String (legado)
        final raw = data["dataNascimento"];
        if (raw is Timestamp) {
          dataNascController.text = _fmtDate(raw.toDate());
        } else if (raw is String) {
          final parsed = _parseBR(raw.trim());
          dataNascController.text = parsed != null ? _fmtDate(parsed) : raw;
        } else {
          dataNascController.text = "";
        }

        sexoSelecionado = data["sexo"] ?? "Prefiro não informar";

        // 🔵 IDS salvos no documento do paciente
        final List<dynamic> ids = data["profissionaisVinculados"] ?? [];

        profissionaisVinculados.clear();

        for (String id in ids.cast<String>()) {
          final pDoc =
          await _firestore.collection("professionals").doc(id).get();

          if (pDoc.exists) {
            profissionaisVinculados.add(
              ProfessionalModel.fromJson(id, pDoc.data()!),
            );
          }
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do paciente: $e");
    }

    notifyListeners();
  }

  // ============================================================
  // 🔵 SALVAR ALTERAÇÕES DO PERFIL
  // ============================================================
  Future<String?> salvarAlteracoes() async {
    final user = _auth.currentUser;
    if (user == null) return "Usuário não autenticado.";

    // ✅ valida data dd/mm/aaaa e salva como Timestamp
    final nascStr = dataNascController.text.trim();
    final nasc = nascStr.isEmpty ? null : _parseBR(nascStr);

    if (nascStr.isNotEmpty && nasc == null) {
      return "Data de nascimento inválida. Use dd/mm/aaaa.";
    }

    try {
      await _firestore.collection("users").doc(user.uid).update({
        "nome": nomeController.text.trim(),
        "telefone": telefoneController.text.trim(),
        "dataNascimento": nasc != null ? Timestamp.fromDate(nasc) : null,
        "sexo": sexoSelecionado,
      });

      // ✅ mantém o campo formatado na UI
      if (nasc != null) {
        dataNascController.text = _fmtDate(nasc);
      }

      return null;
    } catch (e) {
      return "Erro ao salvar: $e";
    }
  }

  // ============================================================
  // 🔵 DESVINCULAR PROFISSIONAL (3 coleções)
  // ============================================================
  Future<void> desvincular(String professionalId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    try {
      // 1️⃣ Remove do documento do usuário
      await _firestore.collection("users").doc(uid).update({
        "profissionaisVinculados": FieldValue.arrayRemove([professionalId]),
      });

      // 2️⃣ Remove da coleção paciente_profissionais/{pacienteId}
      final docPaciente =
      _firestore.collection("paciente_profissionais").doc(uid);

      if ((await docPaciente.get()).exists) {
        await docPaciente.update({
          "profissionais": FieldValue.arrayRemove([professionalId]),
        });
      }

      // 3️⃣ Remove da coleção profissional_pacientes/{profissionalId}
      final docProfissional =
      _firestore.collection("profissional_pacientes").doc(professionalId);

      if ((await docProfissional.get()).exists) {
        await docProfissional.update({
          "pacientes": FieldValue.arrayRemove([uid]),
        });
      }

      // 4️⃣ Remove da lista local
      profissionaisVinculados.removeWhere((p) => p.id == professionalId);
    } catch (e) {
      print("Erro ao desvincular profissional: $e");
    }

    notifyListeners();
  }

  // ============================================================
  // 🔵 LIMPAR CONTROLLERS
  // ============================================================
  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    dataNascController.dispose();
    super.dispose();
  }
}
