import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../Controller/about_controller.dart';

class AboutView extends StatelessWidget {
  final AboutController controller = AboutController();

  AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o MoodSync'),
        backgroundColor: AppColors.blueLogo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        // Gradiente de fundo suave
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.blueLogo.withOpacity(0.15),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Halo e bolhas discretas FORA do cartão
            Positioned(
              top: -40,
              left: -60,
              child: _radialHalo(360, AppColors.blueLogo.withOpacity(0.30)),
            ),
            Positioned(
              top: 80,
              right: -20,
              child: _bubble(130, AppColors.blueLogo.withOpacity(0.18)),
            ),
            Positioned(
              bottom: 30,
              left: -10,
              child: _bubble(140, AppColors.blueLogo.withOpacity(0.12)),
            ),
            Positioned(
              bottom: -70,
              right: -50,
              child: _bubble(220, AppColors.blueLogo.withOpacity(0.14)),
            ),

            // Conteúdo principal (card “glass” + scroll)
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo opcional (comente se não quiser)
                              Center(
                                child: Column(
                                  children: [
                                    Image.asset('lib/images/MoodSyncLogo.png', height: 96),
                                    const SizedBox(height: 8),
                                    Text(
                                      'MOODSYNC',
                                      style: TextStyle(
                                        color: AppColors.fontLogo,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Divider(height: 1),

                              // Tema do Projeto
                              const SizedBox(height: 18),
                              _sectionHeader(
                                icon: Icons.topic_outlined,
                                title: 'Tema do Projeto',
                                color: AppColors.blueLogo,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.tema,
                                style: const TextStyle(fontSize: 16, height: 1.4),
                              ),

                              // Objetivo
                              const SizedBox(height: 22),
                              _sectionHeader(
                                icon: Icons.flag_outlined,
                                title: 'Objetivo do aplicativo',
                                color: AppColors.blueLogo,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.objetivo,
                                style: const TextStyle(fontSize: 16, height: 1.4),
                              ),

                              // Equipe
                              const SizedBox(height: 22),
                              _sectionHeader(
                                icon: Icons.group_outlined,
                                title: 'Equipe de desenvolvimento',
                                color: AppColors.blueLogo,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                controller.equipe,
                                style: const TextStyle(fontSize: 16, height: 1.4),
                              ),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== helpers visuais =====

  Widget _sectionHeader({required IconData icon, required String title, required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _radialHalo(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          radius: 0.85,
          colors: [
            color,
            color.withOpacity(0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
