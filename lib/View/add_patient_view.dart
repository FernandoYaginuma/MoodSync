import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android2/Controller/professional_home_controller.dart';
import 'package:android2/theme/colors.dart';

class AddPatientView extends StatefulWidget {
  final String profissionalId;
  final String profissionalNome;
  final VoidCallback onPacienteAdicionado;

  const AddPatientView({
    super.key,
    required this.profissionalId,
    required this.profissionalNome,
    required this.onPacienteAdicionado,
  });

  @override
  State<AddPatientView> createState() => _AddPatientViewState();
}

class _AddPatientViewState extends State<AddPatientView> {
  final _controller = ProfessionalHomeController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _enviarSolicitacao() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    final erro = await _controller.adicionarPaciente(
      widget.profissionalId,
      widget.profissionalNome,
      email,
    );

    setState(() => _isLoading = false);

    if (erro != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(erro)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Solicitação enviada. Aguarde a confirmação do paciente.",
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Paciente"),
        backgroundColor: AppColors.blueLogo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "E-mail do paciente",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _enviarSolicitacao,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Enviar solicitação"),
            ),
          ],
        ),
      ),
    );
  }
}
