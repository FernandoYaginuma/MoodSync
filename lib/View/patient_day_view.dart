import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android2/Controller/patient_day_controller.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Model/day_model.dart';

class PatientDayView extends StatefulWidget {
  final String pacienteId;
  final DateTime date;

  const PatientDayView({
    super.key,
    required this.pacienteId,
    required this.date,
  });

  @override
  State<PatientDayView> createState() => _PatientDayViewState();
}

class _PatientDayViewState extends State<PatientDayView> {
  late final PatientDayController controller;
  DayModel? day;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    controller = PatientDayController(
      pacienteId: widget.pacienteId,
      data: widget.date,
    );
    carregar();
  }

  Future<void> carregar() async {
    final result = await controller.carregarDia();
    if (mounted) {
      setState(() {
        day = result;
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          "${widget.date.day.toString().padLeft(2, '0')}/"
              "${widget.date.month.toString().padLeft(2, '0')}/"
              "${widget.date.year}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _secaoTitulo("Sentimentos"),
                        _caixa(
                          (day?.emotions.isNotEmpty ?? false)
                              ? day!.emotions.join(', ')
                              : "Sem sentimentos registrados",
                        ),

                        const SizedBox(height: 24),
                        _secaoTitulo("Anotação"),
                        _caixa(
                          (day?.note.trim().isNotEmpty ?? false)
                              ? day!.note
                              : "Sem anotação registrada",
                        ),

                        if (day?.activityIds.isNotEmpty == true) ...[
                          const SizedBox(height: 24),
                          _secaoTitulo("Atividades"),
                          _caixa(day!.activityIds.join(", ")),
                        ],

                        if (day?.lastUpdatedAt != null) ...[
                          const SizedBox(height: 28),
                          Text(
                            "Última atualização: ${day!.lastUpdatedAt}",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secaoTitulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: AppColors.blackBackground,
      ),
    );
  }

  Widget _caixa(String texto) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 16,
          height: 1.4,
          color: Colors.black87,
        ),
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
                AppColors.blueLogo.withOpacity(0.88),
                Colors.white,
              ],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -50,
          child: _bubble(260, AppColors.blueLogo.withOpacity(0.23)),
        ),
        Positioned(
          bottom: -80,
          left: -40,
          child: _bubble(280, AppColors.blueLogo.withOpacity(0.18)),
        ),
      ],
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
