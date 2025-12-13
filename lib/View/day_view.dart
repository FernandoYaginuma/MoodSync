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

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<Map<String, dynamic>> _fetchInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    final safeDate = _dateOnly(widget.selectedDate);

    DayModel dayModel;
    bool jaSalvo = false;

    if (user != null) {
      final docId = DayModel(date: safeDate).formattedDate;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('moodEntries')
          .doc(docId);

      final docSnapshot = await docRef.get();
      jaSalvo = docSnapshot.exists;

      if (docSnapshot.exists) {
        dayModel = DayModel.fromFirestore(docSnapshot);
      } else {
        dayModel = DayModel(date: safeDate);
      }
    } else {
      dayModel = DayModel(date: safeDate);
    }

    final activitiesSnapshot =
        await FirebaseFirestore.instance.collection('activities').get();

    final activities = activitiesSnapshot.docs
        .map((doc) => ActivityModel.fromFirestore(doc.data(), doc.id))
        .toList();

    return {
      'dayModel': dayModel,
      'activities': activities,
      'jaSalvo': jaSalvo,
    };
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

        final DayModel initialDay = snapshot.data!['dayModel'] as DayModel;
        final List<ActivityModel> availableActivities =
            snapshot.data!['activities'] as List<ActivityModel>;
        final bool jaSalvo = snapshot.data!['jaSalvo'] as bool;

        return DayViewContent(
          initialDay: initialDay,
          availableActivities: availableActivities,
          jaSalvo: jaSalvo,
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

  /// ✅ novo: se true, sentimentos não podem ser alterados
  final bool jaSalvo;

  const DayViewContent({
    super.key,
    required this.initialDay,
    required this.availableActivities,
    required this.jaSalvo,
  });

  @override
  State<DayViewContent> createState() => _DayViewContentState();
}

class _DayViewContentState extends State<DayViewContent> {
  late final DayController _controller;
  late final TextEditingController _muralController;

  late bool _emotionsLocked;

  @override
  void initState() {
    super.initState();
    _controller = DayController(day: widget.initialDay);
    _muralController = TextEditingController(text: widget.initialDay.note);

    _emotionsLocked = widget.jaSalvo;

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

  Future<void> _salvar() async {
    await _controller.salvar(_muralController.text);
    if (!mounted) return;

    // ✅ depois de salvar, trava sentimentos (extra segurança, mesmo que volte)
    _emotionsLocked = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salvo com sucesso!')),
    );

    Navigator.pop(context, true);
  }

  void _escolherSentimento() async {
    if (_emotionsLocked) return; // ✅ trava

    final emotions = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => FeelingsView(
          initialSelected: _controller.day.emotions,
        ),
      ),
    );

    if (emotions != null) {
      // ✅ só aplica se não estiver travado
      if (_emotionsLocked) return;
      _controller.setEmotions(emotions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.initialDay.date;
    final dateFormatted =
        "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

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
                      onPressed: _emotionsLocked ? null : _escolherSentimento,
                      icon: const Icon(Icons.mood),
                      label: Text(
                        _emotionsLocked
                            ? "Sentimentos já registrados"
                            : "Escolher sentimentos",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fontLogo.withOpacity(0.12),
                        foregroundColor: AppColors.fontLogo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  if (_emotionsLocked) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "Os sentimentos desse dia já foram salvos e não podem ser alterados.",
                      textAlign: TextAlign.center,
                    ),
                  ],

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
