import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android2/Controller/professional_home_controller.dart';
import 'package:android2/Model/patient_model.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/View/add_patient_view.dart';
import 'package:android2/View/profile_view.dart';
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

        // 🔹 Logout no canto esquerdo (AGORA FUNCIONA)
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (_) => false);
            }
          },
        ),

        title: Text(
          "Olá, ${widget.profissionalNome.split(' ').first}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),

        // 🔹 Perfil no canto direito
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileView()),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ValueListenableBuilder<List<PatientModel>>(
                valueListenable: controller.pacientes,
                builder: (context, pacientes, _) {
                  if (pacientes.isEmpty) {
                    return _mensagemSemPacientes();
                  }

                  return ListView.builder(
                    itemCount: pacientes.length,
                    itemBuilder: (context, index) {
                      final paciente = pacientes[index];
                      return _cardPaciente(paciente);
                    },
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

  // ============================================================
  // UI COMPONENTS
  // ============================================================

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.blueLogo.withOpacity(0.85),
                Colors.white,
              ],
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -100,
          child: _bubble(300, AppColors.blueLogo.withOpacity(0.25)),
        ),
        Positioned(
          top: 100,
          right: -80,
          child: _bubble(220, AppColors.blueLogo.withOpacity(0.20)),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: _bubble(250, AppColors.blueLogo.withOpacity(0.18)),
        ),
      ],
    );
  }

  Widget _mensagemSemPacientes() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              "Nenhum paciente adicionado ainda.\nAdicione seu primeiro paciente abaixo!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardPaciente(PatientModel paciente) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.blueLogo.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.black54),
              ),
              title: Text(
                paciente.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(paciente.email),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              onTap: () {
                // abrir calendário do paciente futuramente
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
