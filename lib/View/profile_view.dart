import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android2/Controller/profile_controller.dart';
import 'package:android2/theme/colors.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final controller = ProfileController();
  bool carregando = true;
  bool salvando = false;

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
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Meu Perfil"),
      ),

      body: Stack(
        children: [
          _buildBackground(),

          carregando
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _campoGlass("Nome", controller.nomeController),
                  const SizedBox(height: 16),
                  _campoGlass("E-mail", controller.emailController, enabled: false),
                  const SizedBox(height: 16),
                  _campoGlass("Telefone", controller.telefoneController,
                      keyboard: TextInputType.phone),
                  const SizedBox(height: 16),
                  _campoGlass("Especialidade", controller.especialidadeController),
                  const SizedBox(height: 16),
                  _campoGlass("Registro Profissional",
                      controller.registroProfissionalController),
                  const SizedBox(height: 16),
                  _campoGlass(
                    "Descrição",
                    controller.descricaoController,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 30),

                  _botaoSalvar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.blueLogo.withOpacity(0.85),
                Colors.white,
              ],
            ),
          ),
        ),

        Positioned(
          top: -80,
          left: -100,
          child: _bubble(300, Colors.white.withOpacity(0.22)),
        ),
        Positioned(
          top: 140,
          right: -120,
          child: _bubble(240, Colors.white.withOpacity(0.18)),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: _bubble(260, Colors.white.withOpacity(0.20)),
        ),
      ],
    );
  }

  Widget _campoGlass(String label, TextEditingController c,
      {bool enabled = true, int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: TextField(
            controller: c,
            enabled: enabled,
            maxLines: maxLines,
            keyboardType: keyboard,
            decoration: InputDecoration(
              labelText: label,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoSalvar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: salvando ? null : _salvar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueLogo,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: salvando
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Text("Salvar alterações",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _salvar() async {
    setState(() => salvando = true);
    final erro = await controller.salvarAlteracoes();
    if (!mounted) return;

    setState(() => salvando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(erro ?? "Dados salvos com sucesso.")),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
