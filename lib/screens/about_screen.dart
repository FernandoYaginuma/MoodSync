import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          children: const [
            Text(
              'Objetivo do aplicativo:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'O MoodSync tem como objetivo auxiliar pacientes e profissionais da saúde mental no acompanhamento emocional diário, promovendo o bem-estar e conectando mentes. ',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Equipe de desenvolvimento:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Fernando Yudi Yaginuma - 837755\n• Arthur Riquieri Campos - 838656',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
