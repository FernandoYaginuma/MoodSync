import 'package:android2/theme/colors.dart';
import 'package:flutter/material.dart';
import 'feelings_view.dart';

class DayView extends StatefulWidget {
  final DateTime selectedDate;

  const DayView({super.key, required this.selectedDate});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  final TextEditingController _muralController = TextEditingController();
  String? _selectedFeeling;

  static final Map<String, Map<String, String>> _savedData = {};

  @override
  void initState() {
    super.initState();
    final key = _formatDate(widget.selectedDate);
    if (_savedData.containsKey(key)) {
      _muralController.text = _savedData[key]?['mural'] ?? '';
      _selectedFeeling = _savedData[key]?['feeling'];
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  void _salvar() {
    final key = _formatDate(widget.selectedDate);
    _savedData[key] = {
      'mural': _muralController.text,
      'feeling': _selectedFeeling ?? '',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Salvo com sucesso!'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pop(context);
  }

  void _escolherSentimento() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeelingsView(
          onFeelingSelected: (String feeling) {
            setState(() {
              _selectedFeeling = feeling;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = "${widget.selectedDate.day.toString().padLeft(2, '0')}/${widget.selectedDate.month.toString().padLeft(2, '0')}/${widget.selectedDate.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Dia $dateFormatted'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedFeeling != null && _selectedFeeling!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Sentimento: $_selectedFeeling",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              "Descreva seu dia:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                foregroundColor: AppColors.blackBackground,
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
                foregroundColor: AppColors.blankBackground,
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
