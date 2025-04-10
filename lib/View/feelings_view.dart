import 'package:android2/theme/colors.dart';
import 'package:flutter/material.dart';

class FeelingsView extends StatefulWidget {
  final Function(String) onFeelingSelected;

  const FeelingsView({super.key, required this.onFeelingSelected});

  @override
  State<FeelingsView> createState() => _FeelingsViewState();
}

class _FeelingsViewState extends State<FeelingsView> {
  String? selectedFeeling;

  final List<String> feelings = [
    "Feliz",
    "Triste",
    "Ansioso",
    "Irritado",
    "Agradecido",
    "Confiante",
    "Cansado",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blankBackground,
      appBar: AppBar(
        title: const Text("Selecione seu sentimento"),
        backgroundColor: AppColors.blueLogo,
        foregroundColor: AppColors.blackBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: feelings.length,
          itemBuilder: (context, index) {
            final feeling = feelings[index];
            final isSelected = selectedFeeling == feeling;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedFeeling = feeling;
                });
                widget.onFeelingSelected(feeling);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.blueLogo : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? AppColors.blueLogo.withAlpha(25) : Colors.transparent,
                ),
                child: Text(
                  feeling,
                  style: TextStyle(
                    fontSize: 18,
                    color: isSelected ? AppColors.blueLogo : AppColors.blackBackground,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
