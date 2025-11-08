import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:android2/Controller/register_controller.dart';
import 'package:android2/theme/colors.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final controller = RegisterController();
  final List<String> sexOptions = [
    'Masculino',
    'Feminino',
    'Outro',
    'Prefiro não informar'
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.dataNascimentoSelecionada ?? DateTime(2000),
      firstDate: DateTime(1920, 1),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != controller.dataNascimentoSelecionada) {
      setState(() {
        controller.dataNascimentoSelecionada = picked;
        controller.dataNascimentoController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: AppColors.blueLogo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.blueLogo.withOpacity(0.25),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Bolhas decorativas
            Positioned(
              top: -60,
              left: -80,
              child: _bubble(300, AppColors.blueLogo.withOpacity(0.25)),
            ),
            Positioned(
              top: 120,
              right: -50,
              child: _bubble(180, AppColors.blueLogo.withOpacity(0.18)),
            ),
            Positioned(
              bottom: -60,
              right: -80,
              child: _bubble(260, AppColors.blueLogo.withOpacity(0.20)),
            ),
            Positioned(
              bottom: 60,
              left: -40,
              child: _bubble(160, AppColors.blueLogo.withOpacity(0.15)),
            ),

            // Conteúdo principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                            const Text(
                              'Preencha seus dados:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            TextFormField(
                              controller: controller.nomeController,
                              decoration: _dec('Nome'),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Informe seu nome'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: controller.emailController,
                              decoration: _dec('E-mail'),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe seu e-mail';
                                }
                                final emailRegex =
                                RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                return emailRegex.hasMatch(value)
                                    ? null
                                    : 'E-mail inválido';
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: controller.telefoneController,
                              decoration: _dec('Telefone'),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe seu telefone';
                                }
                                final digitsOnly =
                                value.replaceAll(RegExp(r'[^0-9]'), '');
                                return digitsOnly.length >= 10
                                    ? null
                                    : 'Telefone inválido';
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: controller.dataNascimentoController,
                              decoration: _dec('Data de Nascimento').copyWith(
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Informe sua data de nascimento'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            DropdownButtonFormField<String>(
                              decoration: _dec('Sexo'),
                              value: controller.sexoSelecionado,
                              items: sexOptions
                                  .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  controller.sexoSelecionado = value;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Selecione uma opção'
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: controller.senhaController,
                              obscureText: true,
                              decoration: _dec('Senha'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira uma senha.';
                                }
                                if (value.length < 8) {
                                  return 'Mínimo de 8 caracteres.';
                                }
                                if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'É necessária ao menos uma letra maiúscula.';
                                }
                                if (!RegExp(r'[a-z]').hasMatch(value)) {
                                  return 'É necessária ao menos uma letra minúscula.';
                                }
                                if (!RegExp(r'[0-9]').hasMatch(value)) {
                                  return 'É necessário ao menos um número.';
                                }
                                if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]')
                                    .hasMatch(value)) {
                                  return 'É necessário ao menos um caractere especial.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: controller.confirmarSenhaController,
                              obscureText: true,
                              decoration: _dec('Confirmar Senha'),
                              validator: (value) =>
                              value != controller.senhaController.text
                                  ? 'As senhas não coincidem'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => controller.cadastrar(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blueLogo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Cadastrar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
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

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );

  Widget _bubble(double size, Color color) => Container(
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
