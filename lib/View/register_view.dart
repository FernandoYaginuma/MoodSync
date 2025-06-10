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
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: AppColors.blueLogo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: controller.nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Informe seu nome' : null,
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
                    if (value == null || value.isEmpty) {
                      return 'Informe seu e-mail';
                    }
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
                    if (value == null || value.isEmpty) {
                      return 'Informe seu telefone';
                    }
                    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                    return digitsOnly.length >= 10 ? null : 'Telefone inválido';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.dataNascimentoController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Informe sua data de nascimento'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Sexo',
                    border: OutlineInputBorder(),
                  ),
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
                  validator: (value) =>
                      value == null ? 'Selecione uma opção' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
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
                    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'É necessário ao menos um caractere especial.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.confirmarSenhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value != controller.senhaController.text
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
                      foregroundColor: const Color.fromRGBO(44, 62, 80, 1),
                    ),
                    child:
                        const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}