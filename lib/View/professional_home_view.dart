import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android2/Controller/professional_home_controller.dart';
import 'package:android2/Model/patient_model.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/View/add_patient_view.dart';
import 'package:android2/View/profile_view.dart';
import 'package:android2/View/patient_calendar_view.dart';
import 'package:android2/View/professional_mural_view.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
            }
          },
        ),
        title: Text(
          "Olá, ${widget.profissionalNome.split(' ').first}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileView()),
                );
              },
              child: const Icon(Icons.person, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ValueListenableBuilder<List<PatientModel>>(
                valueListenable: controller.pacientes,
                builder: (context, pacientes, _) {
                  if (pacientes.isEmpty) {
                    return _mensagemSemPacientes();
                  }

                  return ListView.builder(
                    itemCount: pacientes.length,
                    itemBuilder: (_, index) =>
                        _cardPaciente(pacientes[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blueLogo,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: const Text(
          "Adicionar Paciente",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPatientView(
                profissionalId: widget.profissionalId,
                profissionalNome: widget.profissionalNome,
                onPacienteAdicionado: () {},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cardPaciente(PatientModel paciente) {
    return ListTile(
      title: Text(paciente.nome),
      subtitle: Text(paciente.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfessionalMuralView(
                    pacienteId: paciente.id,
                    pacienteNome: paciente.nome,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientCalendarView(
                    pacienteId: paciente.id,
                    pacienteNome: paciente.nome,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.blueLogo.withOpacity(0.85), Colors.white],
      ),
    ),
  );

  Widget _mensagemSemPacientes() => const Center(
    child: Text(
      "Nenhum paciente vinculado ainda.",
      textAlign: TextAlign.center,
    ),
  );
}
