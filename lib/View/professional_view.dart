import 'package:android2/theme/colors.dart';
import 'package:flutter/material.dart';

class ProfessionalView extends StatefulWidget {
  const ProfessionalView({super.key});

  @override
  State<ProfessionalView> createState() => _ProfessionalViewState();
}

class _ProfessionalViewState extends State<ProfessionalView> {
  final List<String> availableProfessionals = ['Fulano', 'Ciclano'];
  final List<String> addedProfessionals = [];

  static final List<String> _savedProfessionals = [];

  @override
  void initState() {
    super.initState();
    addedProfessionals.addAll(_savedProfessionals);
  }

  void _addProfessional(String name) {
    if (!addedProfessionals.contains(name)) {
      setState(() {
        addedProfessionals.add(name);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name adicionado com sucesso!')),
      );
    }
  }

  void _removeProfessional(String name) {
    setState(() {
      addedProfessionals.remove(name);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name removido.')),
    );
  }

  void _saveProfessionals() {
    _savedProfessionals
      ..clear()
      ..addAll(addedProfessionals);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profissionais salvos!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Profissional')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Disponíveis para adicionar:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...availableProfessionals.map((name) => Card(
                  child: ListTile(
                    title: Text(name),
                    trailing: ElevatedButton(
                      onPressed: () => _addProfessional(name),
                      child: const Text("Adicionar"),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            const Text(
              "Profissionais já adicionados:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...addedProfessionals.map((name) => Card(
                  child: ListTile(
                    title: Text(name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeProfessional(name),
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfessionals,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueLogo,
                foregroundColor: AppColors.blankBackground,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
