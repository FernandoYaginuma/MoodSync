import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:android2/theme/colors.dart';
import 'package:android2/Controller/register_controller.dart';
import 'package:android2/Controller/profissional_register_controller.dart';

import 'terms_view.dart';
import 'privacy_view.dart'; // 🔵 NOVO

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final RegisterController patientController = RegisterController();
  final ProfessionalRegisterController professionalController =
  ProfessionalRegisterController();

  // TERmos e privacidade
  bool aceitaTermosPaciente = false;
  bool aceitaPrivacidadePaciente = false;

  bool aceitaTermosProfissional = false;
  bool aceitaPrivacidadeProfissional = false;

  final List<String> sexOptions = [
    'Masculino',
    'Feminino',
    'Outro',
    'Prefiro não informar'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    patientController.dispose();
    professionalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
      patientController.dataNascimentoSelecionada ?? DateTime(2000),
      firstDate: DateTime(1920, 1),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        patientController.dataNascimentoSelecionada = picked;
        patientController.dataNascimentoController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blueLogo,
        foregroundColor: Colors.white,
        title: const Text(
          'Cadastro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              labelColor: AppColors.blueLogo,
              unselectedLabelColor: Colors.white,
              tabs: const [
                Tab(icon: Icon(Icons.person_outline), text: 'Paciente'),
                Tab(
                    icon: Icon(Icons.medical_services_outlined),
                    text: 'Profissional'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.blueLogo.withOpacity(0.25),
                Colors.white,
              ]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _scrollableForm(_buildPatientForm(context)),
                        _scrollableForm(_buildProfessionalForm(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _scrollableForm(Widget form) =>
      SingleChildScrollView(child: form);

  // --------------------------- PACIENTE ---------------------------
  Widget _buildPatientForm(BuildContext context) {
    final c = patientController;

    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Cadastro de Paciente',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          TextFormField(
            controller: c.nomeController,
            decoration: _dec('Nome completo'),
            validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.emailController,
            decoration: _dec('E-mail'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.telefoneController,
            decoration: _dec('Telefone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.dataNascimentoController,
            readOnly: true,
            decoration: _dec('Data de Nascimento')
                .copyWith(suffixIcon: const Icon(Icons.calendar_today)),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField(
            decoration: _dec('Sexo'),
            value: c.sexoSelecionado,
            items: sexOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) => setState(() => c.sexoSelecionado = value),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.senhaController,
            decoration: _dec('Senha'),
            obscureText: true,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.confirmarSenhaController,
            decoration: _dec('Confirmar senha'),
            obscureText: true,
            validator: (v) =>
            v != c.senhaController.text ? 'As senhas não coincidem' : null,
          ),

          const SizedBox(height: 16),

          // 🔵 Termos Uso
          _checkboxLink(
            aceitaTermosPaciente,
                (v) => setState(() => aceitaTermosPaciente = v!),
            "Termos de Uso",
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TermsView()),
            ),
          ),

          // 🔵 Política privacidade
          _checkboxLink(
            aceitaPrivacidadePaciente,
                (v) => setState(() => aceitaPrivacidadePaciente = v!),
            "Política de Privacidade",
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PrivacyView()),
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton(
            onPressed: () {
              if (!aceitaTermosPaciente || !aceitaPrivacidadePaciente) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Você precisa aceitar os Termos e a Política.'),
                  ),
                );
                return;
              }
              c.cadastrar(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueLogo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Cadastrar Paciente'),
          )
        ],
      ),
    );
  }

  // --------------------------- PROFISSIONAL ---------------------------
  Widget _buildProfessionalForm(BuildContext context) {
    final c = professionalController;

    return Form(
      key: c.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Cadastro de Profissional',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          TextFormField(
            controller: c.nomeController,
            decoration: _dec('Nome completo'),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.emailController,
            decoration: _dec('E-mail'),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.telefoneController,
            decoration: _dec('Telefone profissional'),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.especialidadeController,
            decoration: _dec('Especialidade'),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.registroProfissionalController,
            decoration: _dec('Registro Profissional (CRP, CRM, etc.)'),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.descricaoController,
            decoration: _dec('Descrição / Apresentação'),
            maxLines: 3,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.senhaController,
            decoration: _dec('Senha'),
            obscureText: true,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: c.confirmarSenhaController,
            decoration: _dec('Confirmar senha'),
            obscureText: true,
            validator: (v) =>
            v != c.senhaController.text ? 'As senhas não coincidem' : null,
          ),

          const SizedBox(height: 16),

          // 🔵 Termos
          _checkboxLink(
            aceitaTermosProfissional,
                (v) => setState(() => aceitaTermosProfissional = v!),
            "Termos de Uso",
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TermsView()),
            ),
          ),

          // 🔵 Política privacidade
          _checkboxLink(
            aceitaPrivacidadeProfissional,
                (v) => setState(() => aceitaPrivacidadeProfissional = v!),
            "Política de Privacidade",
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PrivacyView()),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              if (!aceitaTermosProfissional ||
                  !aceitaPrivacidadeProfissional) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Você precisa aceitar os Termos e a Política.'),
                  ),
                );
                return;
              }

              c.cadastrar(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueLogo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Cadastrar Profissional'),
          )
        ],
      ),
    );
  }

  // DECORAÇÃO DE INPUT
  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14)),
  );

  // COMPONENTE REUTILIZÁVEL PARA TERmos E POLÍTICA
  Widget _checkboxLink(
      bool value,
      Function(bool?) onChanged,
      String linkText,
      VoidCallback onTap,
      ) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text.rich(
              TextSpan(
                text: 'Li e concordo com a ',
                children: [
                  TextSpan(
                    text: linkText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
