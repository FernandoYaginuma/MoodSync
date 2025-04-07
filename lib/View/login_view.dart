import 'package:flutter/material.dart';
import 'package:android2/Controller/login_controller.dart';
import 'package:android2/theme/colors.dart';

class LoginView extends StatelessWidget {
  final LoginController controller = LoginController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'lib/images/MoodSyncLogo.png',
                  height: 250,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário ou E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(color: AppColors.blueLogo),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.login(context),
                    child: const Text('Entrar'),
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
    );
  }
}
