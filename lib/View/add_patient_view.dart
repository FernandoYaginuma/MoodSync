import 'package:flutter/material.dart';
import 'package:android2/Controller/professional_home_controller.dart';
import 'package:android2/theme/colors.dart';

class AddPatientView extends StatefulWidget {
  final String profissionalId;
  final VoidCallback onPacienteAdicionado; // callback para atualizar lista na tela anterior

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
      widget.onPacienteAdicionado(); // atualiza a lista
      Navigator.pop(context); // volta pra tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        backgroundColor: AppColors.blueLogo,
        foregroundColor: Colors.white,
        title: const Text("Adicionar Paciente"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Informe o e-mail do paciente para vinculá-lo à sua conta.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-mail do Paciente",
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _adicionarPaciente,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLogo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Adicionar Paciente",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
