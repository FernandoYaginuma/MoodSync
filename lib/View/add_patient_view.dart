import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android2/Controller/professional_home_controller.dart';
import 'package:android2/theme/colors.dart';

class AddPatientView extends StatefulWidget {
  final String profissionalId;
  final VoidCallback onPacienteAdicionado;

  const AddPatientView({
    super.key,
    required this.profissionalId,
    required this.onPacienteAdicionado,
  });

  @override
  State<AddPatientView> createState() => _AddPatientViewState();
}

class _AddPatientViewState extends State<AddPatientView> {
  final _controller = ProfessionalHomeController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _adicionarPaciente() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, insira o e-mail do paciente.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final erro = await _controller.adicionarPaciente(widget.profissionalId, email);

    setState(() => _isLoading = false);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Paciente adicionado com sucesso!")),
      );
      widget.onPacienteAdicionado();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Adicionar Paciente",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fundo com gradiente e bolhas suaves
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.blueLogo.withOpacity(0.8),
                  Colors.white,
                ],
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -60,
            child: _bubble(280, AppColors.blueLogo.withOpacity(0.3)),
          ),
          Positioned(
            top: 100,
            right: -80,
            child: _bubble(220, AppColors.blueLogo.withOpacity(0.2)),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _bubble(250, AppColors.blueLogo.withOpacity(0.25)),
          ),

          // Conteúdo principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(Icons.person_add_alt_1,
                            size: 70, color: Colors.black54),
                        const SizedBox(height: 16),
                        const Text(
                          "Adicionar Paciente",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Informe o e-mail do paciente para vinculá-lo à sua conta profissional.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        const SizedBox(height: 30),

                        // Campo de e-mail
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "E-mail do Paciente",
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Botão de adicionar
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _adicionarPaciente,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueLogo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              "Adicionar Paciente",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                          label: const Text("Voltar"),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.blueLogo,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}
