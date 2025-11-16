import 'package:flutter/material.dart';
import 'package:android2/Controller/mural_controller.dart';
import 'package:android2/Model/mural_model.dart';
import 'package:android2/theme/colors.dart';

class ProfessionalMuralView extends StatefulWidget {
  final String pacienteId;
  final String pacienteNome;

  const ProfessionalMuralView({
    super.key,
    required this.pacienteId,
    required this.pacienteNome,
  });

  @override
  State<ProfessionalMuralView> createState() => _ProfessionalMuralViewState();
}

class _ProfessionalMuralViewState extends State<ProfessionalMuralView> {
  late MuralController controller;
  final msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = MuralController(widget.pacienteId);
  }

  void enviarMensagem() async {
    final texto = msgController.text.trim();
    if (texto.isEmpty) return;

    await controller.enviarMensagem(
      texto: texto,
      autor: "profissional",
    );

    msgController.clear();
    Navigator.pop(context);
  }

  void abrirDialogEnviar() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enviar mensagem"),
        content: TextField(
          controller: msgController,
          decoration: const InputDecoration(hintText: "Digite a mensagem..."),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: enviarMensagem,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueLogo,
            ),
            child: const Text("Enviar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mural de ${widget.pacienteNome}"),
        backgroundColor: AppColors.blueLogo,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: abrirDialogEnviar,
        backgroundColor: AppColors.blueLogo,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder<List<MuralMessage>>(
        stream: controller.getMensagens(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final mensagens = snap.data!;

          if (mensagens.isEmpty) {
            return const Center(child: Text("Nenhuma mensagem ainda."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: mensagens.length,
            itemBuilder: (_, i) {
              final msg = mensagens[i];

              return Dismissible(
                key: Key(msg.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => controller.apagarMensagem(msg.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),
                child: Card(
                  child: ListTile(
                    title: Text(msg.texto),
                    subtitle: Text(
                      msg.autor == "profissional"
                          ? "Enviado por você"
                          : "Enviado pelo paciente",
                    ),
                    trailing: Text(
                      "${msg.criadoEm.day}/${msg.criadoEm.month}",
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
