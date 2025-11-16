import 'package:flutter/material.dart';
import 'package:android2/theme/colors.dart';
import 'package:android2/Utils/emotions_utils.dart'; // 👈 AJUSTADO

class FeelingsView extends StatefulWidget {
  final List<String> initialSelected;

  const FeelingsView({
    super.key,
    required this.initialSelected,
  });

  @override
  State<FeelingsView> createState() => _FeelingsViewState();
}

class _FeelingsViewState extends State<FeelingsView> {
  late List<String> selectedFeelings;

  @override
  void initState() {
    super.initState();
    selectedFeelings = List<String>.from(widget.initialSelected);
  }

  void _toggleFeeling(String feeling) {
    setState(() {
      if (selectedFeelings.contains(feeling)) {
        selectedFeelings.remove(feeling);
      } else {
        if (selectedFeelings.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Você pode escolher até 3 sentimentos."),
            ),
          );
          return;
        }
        selectedFeelings.add(feeling);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // TITLE
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.fontLogo,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Selecione seus sentimentos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.fontLogo,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      children: [
                        _buildCategory("Positivas", EmotionUtils.positive),
                        const SizedBox(height: 20),
                        _buildCategory("Negativas", EmotionUtils.negative),
                        const SizedBox(height: 20),
                        _buildCategory("Sociais", EmotionUtils.social),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueLogo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop<List<String>>(
                          context,
                          selectedFeelings,
                        );
                      },
                      child: const Text(
                        "Confirmar sentimentos",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, String category) {
    final list = EmotionUtils.emotions
        .where((e) => EmotionUtils.emotionCategory[e] == category)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blackBackground,
          ),
        ),
        const SizedBox(height: 10),
        ...list.map((feeling) => _buildFeelingItem(feeling)),
      ],
    );
  }

  Widget _buildFeelingItem(String feeling) {
    final isSelected = selectedFeelings.contains(feeling);
    final color = EmotionUtils.emotionColor(feeling);

    return GestureDetector(
      onTap: () => _toggleFeeling(feeling),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, size: 16, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feeling,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
