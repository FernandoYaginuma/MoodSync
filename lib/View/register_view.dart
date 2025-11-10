import 'dart:ui';
import 'package:android2/Controller/profissional_register_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:android2/Controller/register_controller.dart';
import 'package:android2/theme/colors.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final RegisterController patientController = RegisterController();
  final ProfessionalRegisterController professionalController = ProfessionalRegisterController();

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: patientController.dataNascimentoSelecionada ?? DateTime(2000),
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
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.blueLogo,
        elevation: 3,
        title: const Text(
          'Cadastro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.blueLogo,
              unselectedLabelColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.person_outline), text: 'Paciente'),
                Tab(icon: Icon(Icons.medical_services_outlined), text: 'Profissional'),
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
            ],
          ),
        ),
        child: Center(
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
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.75,
                    ),
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

  Widget _scrollableForm(Widget form) => SingleChildScrollView(child: form);

  // --------------------------- Paciente ---------------------------
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
            validator: (v) => v!.contains('@') ? null : 'E-mail inválido',
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
            decoration: _dec('Data de Nascimento').copyWith(
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: _dec('Sexo'),
            value: c.sexoSelecionado,
            items: sexOptions
                .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                .toList(),
            onChanged: (value) => setState(() => c.sexoSelecionado = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: c.senhaController,
            decoration: _dec('Senha'),
            obscureText: true,
            validator: (v) => v!.length < 8 ? 'Mínimo de 8 caracteres' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: c.confirmarSenhaController,
            decoration: _dec('Confirmar senha'),
            obscureText: true,
            validator: (v) =>
            v != c.senhaController.text ? 'As senhas não coincidem' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => c.cadastrar(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueLogo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Cadastrar Paciente'),
          ),
        ],
      ),
    );
  }

  // --------------------------- Profissional ---------------------------
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
          TextFormField(controller: c.nomeController, decoration: _dec('Nome completo')),
          const SizedBox(height: 12),
          TextFormField(controller: c.emailController, decoration: _dec('E-mail')),
          const SizedBox(height: 12),
          TextFormField(controller: c.telefoneController, decoration: _dec('Telefone profissional')),
          const SizedBox(height: 12),
          TextFormField(controller: c.especialidadeController, decoration: _dec('Especialidade')),
          const SizedBox(height: 12),
          TextFormField(controller: c.registroProfissionalController, decoration: _dec('Registro Profissional (CRP, CRM, etc.)')),
          const SizedBox(height: 12),
          TextFormField(controller: c.descricaoController, decoration: _dec('Descrição / Apresentação'), maxLines: 3),
          const SizedBox(height: 12),
          TextFormField(controller: c.senhaController, decoration: _dec('Senha'), obscureText: true),
          const SizedBox(height: 12),
          TextFormField(
            controller: c.confirmarSenhaController,
            decoration: _dec('Confirmar senha'),
            obscureText: true,
            validator: (v) => v != c.senhaController.text ? 'As senhas não coincidem' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => c.cadastrar(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueLogo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Cadastrar Profissional'),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );

  Widget _bubble(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}
