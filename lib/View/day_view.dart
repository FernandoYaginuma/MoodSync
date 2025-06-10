import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/Controller/day_controller.dart';
import 'feelings_view.dart';

class DayView extends StatefulWidget {
  final DateTime selectedDate;

  const DayView({super.key, required this.selectedDate});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late final Future<DayModel> _dayDataFuture;

  @override
  void initState() {
    super.initState();
    _dayDataFuture = _fetchDayData();
  }

  Future<DayModel> _fetchDayData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return DayModel(date: widget.selectedDate);
    }

    final docId = DayModel(date: widget.selectedDate).formattedDate;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moodEntries')
        .doc(docId);

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      return DayModel.fromJson(docSnapshot.data()!);
    } else {
      return DayModel(date: widget.selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DayModel>(
      future: _dayDataFuture,
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
            body: const Center(child: Text("Não foi possível carregar os dados.")),
          );
        }

        final initialDay = snapshot.data!;
        return DayViewContent(initialDay: initialDay);
      },
    );
  }
}

class DayViewContent extends StatefulWidget {
  final DayModel initialDay;

  const DayViewContent({super.key, required this.initialDay});

  @override
  State<DayViewContent> createState() => _DayViewContentState();
}

class _DayViewContentState extends State<DayViewContent> {
  late final DayController _controller;
  late final TextEditingController _muralController;

  void _rebuildOnNotify() {
    if(mounted) {
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
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    "Descreva seu dia:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: TextField(
                      controller: _muralController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.blueLogo),
                        ),
                        hintText: 'Escreva aqui...',
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _escolherSentimento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blankBackground,
                      foregroundColor: AppColors.fontLogo,
                      side: const BorderSide(color: AppColors.blackBackground),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Escolher sentimento"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueLogo,
                      foregroundColor: AppColors.fontLogo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Salvar"),
                  ),
                ],
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