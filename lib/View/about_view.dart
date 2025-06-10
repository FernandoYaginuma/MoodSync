import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../Controller/about_controller.dart';

class AboutView extends StatelessWidget {
  final AboutController controller = AboutController();

  AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        title: const Text('Sobre o MoodSync'),
        backgroundColor: AppColors.blueLogo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tema do Projeto:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              controller.tema,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Objetivo do aplicativo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              controller.objetivo,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Equipe de desenvolvimento:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              controller.equipe,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}