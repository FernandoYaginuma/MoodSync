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
      // Fundo gradiente com bolhas
      body: Stack(
        children: [
          // Fundo com gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Bolhas decorativas
          Positioned(
            top: -50,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.blueLogo.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.blueLogo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Conteúdo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // AppBar customizado
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.fontLogo,
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Selecione seu sentimento",
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
                            Future.delayed(const Duration(milliseconds: 200),
                                    () {
                                  widget.onFeelingSelected(feeling);
                                });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.blueLogo.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.blueLogo
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: AppColors.blueLogo.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                feeling,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isSelected
                                      ? AppColors.blueLogo
                                      : AppColors.blackBackground,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
}
