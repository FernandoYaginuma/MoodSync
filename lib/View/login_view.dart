import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android2/Controller/login_controller.dart';
import 'package:android2/theme/colors.dart';

class LoginHomeView extends StatelessWidget {
  final LoginController controller = LoginController();
  LoginHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            // === FUNDO SUPERIOR ===
            Positioned(
              top: -40,
              left: -60,
              child: _radialHalo(400, AppColors.blueLogo.withOpacity(0.35)),
            ),
            Positioned(
              top: 60,
              right: -10,
              child: _bubble(160, AppColors.blueLogo.withOpacity(0.26)),
            ),
            Positioned(
              top: 140,
              left: -20,
              child: _bubble(100, AppColors.fontLogo.withOpacity(0.18)),
            ),

            // === BOLHAS INFERIORES ===
            Positioned(
              bottom: 40,
              left: -20,
              child: _bubble(150, AppColors.fontLogo.withOpacity(0.14)),
            ),
            Positioned(
              bottom: -70,
              right: -50,
              child: _bubble(230, AppColors.blueLogo.withOpacity(0.16)),
            ),

            // === CARTÃO DO FORM ===
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ================================
                              // LOGO (SEM TEXTO DUPLICADO)
                              // ================================
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'lib/images/MoodSyncLogo.png',
                                      height: 140,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 10),

                              // INPUTS -------------------------
                              _input(
                                label: 'E-mail',
                                controller: controller.emailController,
                                keyboard: TextInputType.emailAddress,
                                validatorMsg: 'Informe seu e-mail',
                                accent: AppColors.blueLogo,
                              ),
                              const SizedBox(height: 12),

                              _input(
                                label: 'Senha',
                                controller: controller.senhaController,
                                obscure: true,
                                validatorMsg: 'Informe sua senha',
                                accent: AppColors.blueLogo,
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                                  child: Text(
                                    'Esqueceu a senha?',
                                    style: TextStyle(color: AppColors.fontLogo),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // BOTÃO ENTRAR --------------------
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () => controller.fazerLogin(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blueLogo,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // BOTÕES SECUNDÁRIOS -------------
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/register'),
                                child: const Text('Cadastrar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/about'),
                                child: const Text('Sobre o Projeto'),
                              ),
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

  // ===== widgets auxiliares =====

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

  InputDecoration _inputDecoration(String label, Color accent) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent.withOpacity(0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    String? validatorMsg,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    required Color accent,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: (v) => (v == null || v.isEmpty) ? validatorMsg : null,
      decoration: _inputDecoration(label, accent),
    );
  }
}
