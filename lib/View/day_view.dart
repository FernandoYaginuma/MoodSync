import 'package:flutter/material.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Model/day_model.dart';
import 'package:android2/Controller/day_controller.dart';
import 'feelings_view.dart';
import 'package:android2/Controller/home_controller.dart';

class DayView extends StatefulWidget {
  final DateTime selectedDate;

  const DayView({super.key, required this.selectedDate});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late final DayController _controller;
  final TextEditingController _muralController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final daySalvo = HomeController().buscarDia(widget.selectedDate);
    final day = daySalvo ?? DayModel(date: widget.selectedDate);
    _controller = DayController(day: day);

    _muralController.text = _controller.day.note;
  }

  void _salvar() {
    _controller.updateNote(_muralController.text);
    HomeController().adicionarDia(_controller.day);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Salvo com sucesso!')),
    );

    Navigator.pop(context);
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
      setState(() {
        _controller.setEmotion(feeling);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        "${widget.selectedDate.day.toString().padLeft(2, '0')}/${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.year}";

    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        title: Text('Dia $dateFormatted'),
        backgroundColor: AppColors.blueLogo,
        foregroundColor: AppColors.blackBackground,
      ),
      body: Padding(
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.blueLogo),
                  ),
                  hintText: 'Escreva aqui...',
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
    );
  }
}
