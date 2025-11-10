import 'package:flutter/material.dart';
import 'package:android2/Controller/professional_home_controller.dart';
import 'package:android2/Model/patient_model.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/View/add_patient_view.dart';

class ProfessionalHomeView extends StatefulWidget {
  final String profissionalId;
  final String profissionalNome;

  const ProfessionalHomeView({
    super.key,
    required this.profissionalId,
    required this.profissionalNome,
  });

  @override
  State<ProfessionalHomeView> createState() => _ProfessionalHomeViewState();
}

class _ProfessionalHomeViewState extends State<ProfessionalHomeView> {
  final controller = ProfessionalHomeController();

  @override
  void initState() {
    super.initState();
    controller.carregarPacientes(widget.profissionalId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        title: Text("Bem-vindo, ${widget.profissionalNome}"),
        backgroundColor: AppColors.blueLogo,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder<List<PatientModel>>(
        valueListenable: controller.pacientes,
        builder: (context, pacientes, _) {
          if (pacientes.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum paciente adicionado ainda.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.black54),
                  ),
                  title: Text(
                    paciente.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(paciente.email),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.black54, size: 18),
                  onTap: () {
                    // TODO: abrir tela de calendário do paciente
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blueLogo,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text("Adicionar Paciente"),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPatientView(
                profissionalId: widget.profissionalId,
                onPacienteAdicionado: () {
                  controller.carregarPacientes(widget.profissionalId);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
