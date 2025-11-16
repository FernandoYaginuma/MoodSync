import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/Model/activity_model.dart';
import 'package:android2/Controller/day_controller.dart';
import 'package:android2/Utils/emotions_utils.dart';
import 'feelings_view.dart';

class DayView extends StatefulWidget {
  final DateTime selectedDate;

  const DayView({super.key, required this.selectedDate});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late final Future<Map<String, dynamic>> _initialDataFuture;

  @override
  void initState() {
    super.initState();
    _initialDataFuture = _fetchInitialData();
  }

  Future<Map<String, dynamic>> _fetchInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    DayModel dayModel;

    if (user != null) {
      final docId = DayModel(date: widget.selectedDate).formattedDate;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('moodEntries')
          .doc(docId);

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        dayModel = DayModel.fromJson(docSnapshot.data()!);
      } else {
        dayModel = DayModel(date: widget.selectedDate);
      }
    } else {
      dayModel = DayModel(date: widget.selectedDate);
    }

    final activitiesSnapshot =
    await FirebaseFirestore.instance.collection('activities').get();

    final activities = activitiesSnapshot.docs
        .map((doc) => ActivityModel.fromFirestore(doc.data(), doc.id))
        .toList();

    return {'dayModel': dayModel, 'activities': activities};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initialDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Carregando...")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erro")),
            body: const Center(
              child: Text("Não foi possível carregar os dados."),
            ),
          );
        }

        final DayModel initialDay = snapshot.data!['dayModel'];
        final List<ActivityModel> availableActivities =
        snapshot.data!['activities'];

        return DayViewContent(
          initialDay: initialDay,
          availableActivities: availableActivities,
        );
      },
    );
  }
}

// ===============================================================
//   CONTEÚDO PRINCIPAL — DayViewContent
// ===============================================================

class DayViewContent extends StatefulWidget {
  final DayModel initialDay;
  final List<ActivityModel> availableActivities;

  const DayViewContent({
    super.key,
    required this.initialDay,
    required this.availableActivities,
  });

  @override
  State<DayViewContent> createState() => _DayViewContentState();
}

class _DayViewContentState extends State<DayViewContent> {
  late final DayController _controller;
  late final TextEditingController _muralController;

  @override
  void initState() {
    super.initState();
    _controller = DayController(day: widget.initialDay);
    _muralController = TextEditingController(text: widget.initialDay.note);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _muralController.dispose();
    super.dispose();
  }

  // 🔴 AQUI É O PULO DO GATO: volta pro calendário retornando TRUE
  Future<void> _salvar() async {
    await _controller.salvar(_muralController.text);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salvo com sucesso!')),
    );

    Navigator.pop(context, true); // 👈 sinaliza pro calendário recarregar
  }

  void _escolherSentimento() async {
    final emotions = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => FeelingsView(
          initialSelected: _controller.day.emotions,
        ),
      ),
    );

    if (emotions != null) {
      _controller.setEmotions(emotions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        "${widget.initialDay.date.day.toString().padLeft(2, '0')}/${widget.initialDay.date.month.toString().padLeft(2, '0')}/${widget.initialDay.date.year}";

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("Dia $dateFormatted"),
        centerTitle: true,
        foregroundColor: AppColors.fontLogo,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Fundo decorativo
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.blueLogo.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.blueLogo.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================
                  //   Emoções selecionadas
                  // ==========================
                  if (_controller.day.emotions.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _controller.day.emotions.map((e) {
                        final color = EmotionUtils.emotionColor(e);
                        return Chip(
                          label: Text(e),
                          backgroundColor: color.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide(color: color),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 18),

                  // ==========================
                  //   Atividades
                  // ==========================
                  const Text(
                    "Atividades do Dia",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActivityChips(),

                  const SizedBox(height: 28),

                  // ==========================
                  //   Mural
                  // ==========================
                  const Text(
                    "Descreva seu dia",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDescriptionBox(),

                  const SizedBox(height: 18),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _escolherSentimento,
                      icon: const Icon(Icons.mood),
                      label: const Text("Escolher sentimentos"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fontLogo.withOpacity(0.12),
                        foregroundColor: AppColors.fontLogo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _salvar,
                      icon: const Icon(Icons.save),
                      label: const Text("Salvar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueLogo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_controller.isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.availableActivities.map((activity) {
        final isSelected = _controller.day.activityIds.contains(activity.id);

        return ChoiceChip(
          label: Text(activity.name),
          selected: isSelected,
          onSelected: (_) => _controller.toggleActivity(activity.id),
          selectedColor: AppColors.blueLogo,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: AppColors.blueLogo.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _muralController,
        maxLines: 6,
        decoration: const InputDecoration(
          hintText: 'Escreva aqui...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14),
        ),
      ),
    );
  }
}
