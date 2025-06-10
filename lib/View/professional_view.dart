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
      final message =
          success ? 'Profissionais salvos!' : 'Erro ao salvar profissionais.';
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
      appBar: AppBar(title: const Text('Buscar e Adicionar Profissional')),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (value) => _controller.search(value),
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar profissional pelo nome...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<ProfessionalSortOrder>(
                  valueListenable: _controller.sortOrder,
                  builder: (context, currentOrder, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Ordenar por:"),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("A-Z"),
                          selected: currentOrder == ProfessionalSortOrder.az,
                          onSelected: (selected) {
                            if (selected) {
                              _controller.setSortOrder(ProfessionalSortOrder.az);
                            } else {
                              _controller.setSortOrder(ProfessionalSortOrder.none);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("Z-A"),
                          selected: currentOrder == ProfessionalSortOrder.za,
                          onSelected: (selected) {
                            if (selected) {
                              _controller.setSortOrder(ProfessionalSortOrder.za);
                            } else {
                              _controller.setSortOrder(ProfessionalSortOrder.none);
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ValueListenableBuilder<List<ProfessionalModel>>(
                    valueListenable: _controller.availableProfessionals,
                    builder: (context, available, _) {
                      if (available.isEmpty) {
                        return const Center(
                            child: Text("Nenhum profissional encontrado."));
                      }
                      return ListView.builder(
                        itemCount: available.length,
                        itemBuilder: (context, index) {
                          final professional = available[index];
                          return Card(
                            child: ListTile(
                              isThreeLine: true,
                              title: Text(professional.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${professional.specialty}\n${professional.city} - CRP: ${professional.crp}'),
                              trailing: ElevatedButton(
                                onPressed: () =>
                                    _controller.addProfessional(professional),
                                child: const Text("Adicionar"),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Meus Profissionais:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ValueListenableBuilder<List<ProfessionalModel>>(
                    valueListenable: _controller.addedProfessionals,
                    builder: (context, added, _) {
                      if (added.isEmpty) {
                        return const Center(
                            child: Text("Nenhum profissional adicionado."));
                      }
                      return ListView.builder(
                        itemCount: added.length,
                        itemBuilder: (context, index) {
                          final professional = added[index];
                          return Card(
                            child: ListTile(
                              title: Text(professional.name),
                              subtitle: Text(professional.specialty),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _controller
                                    .removeProfessional(professional),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
          );
        },
      ),
    );
  }
}