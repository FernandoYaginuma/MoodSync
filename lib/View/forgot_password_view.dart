import 'package:flutter/material.dart';
import 'package:android2/Controller/forgot_password_controller.dart';
import 'package:android2/theme/colors.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final controller = ForgotPasswordController();
  bool emailConfirmado = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void validarEmail() async {
    final email = controller.emailController.text.trim();
    final existe = await controller.verificarEmail(email);

    if (existe) {
      setState(() {
        emailConfirmado = true;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail não encontrado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        backgroundColor: AppColors.blueLogo,
        foregroundColor: AppColors.blackBackground,
        title: const Text('Recuperar Senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!emailConfirmado) ...[
              const Text(
                'Digite seu e-mail para redefinir a senha:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.blackBackground,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueLogo,
                    foregroundColor: AppColors.fontLogo,
                  ),
                  onPressed: validarEmail,
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ] else ...[
              const Text(
                'Digite sua nova senha:',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.blackBackground,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.novaSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueLogo,
                    foregroundColor: AppColors.fontLogo,
                  ),
                  onPressed: () => controller.redefinirSenha(context),
                  child: const Text(
                    'Redefinir Senha',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
