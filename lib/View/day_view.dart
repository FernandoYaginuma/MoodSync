import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/Model/activity_model.dart';
import 'package:android2/Controller/day_controller.dart';
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
            body:
                const Center(child: Text("Não foi possível carregar os dados.")),
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

  final Map<String, IconData> _iconMap = {
    'fitness_center': Icons.fitness_center,
    'self_improvement': Icons.self_improvement,
    'people': Icons.people,
    'work': Icons.work,
    'palette': Icons.palette,
    'circle': Icons.circle,
  };

  void _rebuildOnNotify() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = DayController(day: widget.initialDay);
    _muralController = TextEditingController(text: widget.initialDay.note);
    _controller.addListener(_rebuildOnNotify);
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuildOnNotify);
    _controller.dispose();
    _muralController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    await _controller.salvar(_muralController.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvo com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  void _escolherSentimento() async {
    final feeling = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => FeelingsView(
          onFeelingSelected: (String feeling) {
            Navigator.pop(context, feeling);
          },
        ),
      ),
    );

    if (feeling != null) {
      _controller.setEmotion(feeling);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        "${widget.initialDay.date.day.toString().padLeft(2, '0')}/${widget.initialDay.date.month.toString().padLeft(2, '0')}/${widget.initialDay.date.year}";

    return AbsorbPointer(
      absorbing: _controller.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.blankBackground,
        appBar: AppBar(
          title: Text('Dia $dateFormatted'),
          backgroundColor: AppColors.blueLogo,
          foregroundColor: AppColors.blackBackground,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_controller.day.emotion != null &&
                        _controller.day.emotion!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.blueLogo.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "Sentimento: ${_controller.day.emotion}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Text("Atividades do Dia:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: widget.availableActivities.map((activity) {
                        final isSelected =
                            _controller.day.activityIds.contains(activity.id);
                        return ChoiceChip(
                          label: Text(activity.name),
                          avatar: Icon(
                              _iconMap[activity.iconName] ?? Icons.circle,
                              color:
                                  isSelected ? Colors.white : Colors.black54),
                          selected: isSelected,
                          onSelected: (selected) {
                            _controller.toggleActivity(activity.id);
                          },
                          selectedColor: AppColors.blueLogo,
                          labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.black),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Descreva seu dia:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _muralController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Escreva aqui...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _escolherSentimento,
                      child: const Text("Escolher sentimento"),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueLogo,
                        foregroundColor: AppColors.fontLogo,
                      ),
                      child: const Text("Salvar"),
                    ),
                  ],
                ),
              ),
            ),
            if (_controller.isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}