import 'package:flutter/material.dart';
import 'package:android2/Controller/mural_controller.dart';
import 'package:android2/Model/mural_model.dart';
import 'package:android2/theme/colors.dart';

class PatientMuralView extends StatefulWidget {
  final String pacienteId;

  const PatientMuralView({
    super.key,
    required this.pacienteId,
  });

  @override
  State<PatientMuralView> createState() => _PatientMuralViewState();
}

class _PatientMuralViewState extends State<PatientMuralView> {
  late MuralController controller;

  @override
  void initState() {
    super.initState();
    controller = MuralController(widget.pacienteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mural"),
        backgroundColor: AppColors.blueLogo,
      ),

      body: StreamBuilder<List<MuralMessage>>(
        stream: controller.getMensagens(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mensagens = snap.data!;

          if (mensagens.isEmpty) {
            return const Center(
              child: Text("Nenhuma mensagem do profissional ainda."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: mensagens.length,
            itemBuilder: (_, i) {
              final msg = mensagens[i];

              return Card(
                color: msg.lido ? Colors.white : Colors.blue.shade50,
                child: ListTile(
                  title: Text(msg.texto),
                  subtitle: Text(
                    "Enviado em: ${msg.criadoEm.day}/${msg.criadoEm.month}/${msg.criadoEm.year}",
                  ),

                  onTap: () {
                    controller.marcarComoLida(msg.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
