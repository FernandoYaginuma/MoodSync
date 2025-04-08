import 'package:flutter/material.dart';
import 'package:android2/Controller/login_controller.dart';
import 'package:android2/theme/colors.dart';

class LoginHomeView extends StatelessWidget {
  final LoginController controller = LoginController();

  LoginHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'lib/images/MoodSyncLogo.png',
                    height: 250,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: controller.usuarioOuEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Usuário ou E-mail',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Informe seu usuário ou e-mail' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Informe sua senha' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(color: AppColors.fontLogo),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => controller.fazerLogin(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.blueLogo,foregroundColor: AppColors.fontLogo),
                      child: const Text('Entrar',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
    );
  }
}
