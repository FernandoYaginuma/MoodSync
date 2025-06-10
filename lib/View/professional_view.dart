import 'package:flutter/material.dart';
import 'package:android2/Controller/professional_controller.dart';
import 'package:android2/Model/professional_model.dart';
import 'package:android2/theme/colors.dart';

class ProfessionalView extends StatefulWidget {
  const ProfessionalView({super.key});

  @override
  State<ProfessionalView> createState() => _ProfessionalViewState();
}

class _ProfessionalViewState extends State<ProfessionalView> {
  final ProfessionalController _controller = ProfessionalController();

  @override
  void initState() {
    super.initState();
    _controller.fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveAndPop() async {
    final success = await _controller.saveProfessionals();
    if (mounted) {
      final message = success
          ? 'Profissionais salvos!'
          : 'Erro ao salvar profissionais.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Profissional')),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Disponíveis para adicionar:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<ProfessionalModel>>(
                    valueListenable: _controller.availableProfessionals,
                    builder: (context, available, _) {
                      return Column(
                        children: available.map((professional) {
                          return Card(
                            child: ListTile(
                              title: Text(professional.name),
                              subtitle: Text(professional.specialty),
                              trailing: ElevatedButton(
                                onPressed: () =>
                                    _controller.addProfessional(professional),
                                child: const Text("Adicionar"),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Profissionais já adicionados:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<List<ProfessionalModel>>(
                    valueListenable: _controller.addedProfessionals,
                    builder: (context, added, _) {
                      if (added.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                              child: Text("Nenhum profissional adicionado.")),
                        );
                      }
                      return Column(
                        children: added.map((professional) {
                          return Card(
                            child: ListTile(
                              title: Text(professional.name),
                              subtitle: Text(professional.specialty),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _controller.removeProfessional(professional),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveAndPop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueLogo,
                      foregroundColor: AppColors.fontLogo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Salvar e Voltar"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}