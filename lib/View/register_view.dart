import 'package:flutter/material.dart';
import 'package:android2/Controller/register_controller.dart';
import 'package:android2/theme/colors.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final controller = RegisterController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: AppColors.blueLogo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: controller.nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe seu e-mail';
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  return emailRegex.hasMatch(value) ? null : 'E-mail inválido';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe seu telefone';
                  final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                  return digitsOnly.length == 11 ? null : 'Telefone inválido';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.length < 6 ? 'Senha muito curta (mín. 6 caracteres)' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.confirmarSenhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value != controller.senhaController.text ? 'As senhas não coincidem' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.cadastrar(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueLogo,
                    foregroundColor: const Color.fromRGBO(44, 62, 80, 1),
                  ),
                  child: const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
