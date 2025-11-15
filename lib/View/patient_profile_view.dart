import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android2/Controller/patient_profile_controller.dart';
import 'package:android2/theme/colors.dart';

class PatientProfileView extends StatefulWidget {
  const PatientProfileView({super.key});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView> {
  final controller = PatientProfileController();
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    await controller.carregarDados();
    if (mounted) setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Meu Perfil",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
              )
            ],
          ),
        ),
        centerTitle: true,
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          _buildBackground(),
          _buildContent(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // 🌈 FUNDO COM GRADIENTE + BOLHAS
  // ------------------------------------------------------------
  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.blueLogo.withOpacity(0.9),
                Colors.white,
              ],
            ),
          ),
        ),

        Positioned(
          top: -40,
          left: -30,
          child: _bubble(160, AppColors.blueLogo.withOpacity(0.25)),
        ),
        Positioned(
          top: 140,
          right: -50,
          child: _bubble(200, AppColors.blueLogo.withOpacity(0.22)),
        ),
        Positioned(
          bottom: -60,
          left: -20,
          child: _bubble(260, AppColors.blueLogo.withOpacity(0.18)),
        ),
      ],
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ------------------------------------------------------------
  // 🧊 CONTEÚDO CENTRAL
  // ------------------------------------------------------------
  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.90),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _input(controller.nomeController, "Nome"),
                  const SizedBox(height: 14),

                  _input(controller.emailController, "E-mail",
                      enabled: false),
                  const SizedBox(height: 14),

                  _input(controller.telefoneController, "Telefone",
                      type: TextInputType.phone),
                  const SizedBox(height: 14),

                  _input(controller.dataNascController,
                      "Data de nascimento (dd/mm/aaaa)",
                      type: TextInputType.datetime),
                  const SizedBox(height: 14),

                  _sexoDropdown(),
                  const SizedBox(height: 26),

                  _botaoSalvar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ✏ INPUT PADRÃO ESTILIZADO
  // ------------------------------------------------------------
  Widget _input(TextEditingController controller, String label,
      {bool enabled = true, TextInputType type = TextInputType.text}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ⚧ DROPDOWN SEXO
  // ------------------------------------------------------------
  Widget _sexoDropdown() {
    return DropdownButtonFormField<String>(
      value: controller.sexoSelecionado,
      items: const [
        DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
        DropdownMenuItem(value: "Feminino", child: Text("Feminino")),
        DropdownMenuItem(value: "Outro", child: Text("Outro")),
        DropdownMenuItem(
          value: "Prefiro não informar",
          child: Text("Prefiro não informar"),
        ),
      ],
      onChanged: (v) =>
          setState(() => controller.sexoSelecionado = v!),
      decoration: InputDecoration(
        labelText: "Sexo",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // 💾 BOTÃO SALVAR
  // ------------------------------------------------------------
  Widget _botaoSalvar() {
    return ElevatedButton(
      onPressed: () async {
        final erro = await controller.salvarAlteracoes();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                erro ?? "Dados salvos com sucesso!"),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.blueLogo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        shadowColor: Colors.black54,
        elevation: 3,
      ),
      child: const Text(
        "Salvar alterações",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    );
  }
}
