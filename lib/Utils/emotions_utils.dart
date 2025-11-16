import 'package:flutter/material.dart';

class EmotionUtils {
  // ==============================
  //  LISTA DAS EMOÇÕES
  // ==============================
  static const List<String> emotions = [
    // POSITIVAS
    "Feliz",
    "Agradecido",
    "Confiante",
    "Calmo",
    "Animado",

    // NEGATIVAS
    "Triste",
    "Irritado",
    "Ansioso",
    "Cansado",
    "Sobrecarregado",

    // SOCIAIS
    "Envergonhado",
    "Solitário",
  ];

  // ==============================
  //  CATEGORIAS
  // ==============================
  static const String positive = "positive";
  static const String negative = "negative";
  static const String social = "social";

  // ==============================
  //  MAPEAMENTO EMOÇÃO → CATEGORIA
  // ==============================
  static const Map<String, String> emotionCategory = {
    // POSITIVAS
    "Feliz": positive,
    "Agradecido": positive,
    "Confiante": positive,
    "Calmo": positive,
    "Animado": positive,

    // NEGATIVAS
    "Triste": negative,
    "Irritado": negative,
    "Ansioso": negative,
    "Cansado": negative,
    "Sobrecarregado": negative,

    // SOCIAIS
    "Envergonhado": social,
    "Solitário": social,
  };

  // ==============================
  //  COR DE CADA CATEGORIA
  // ==============================
  static Color emotionColor(String emotion) {
    final category = emotionCategory[emotion];

    switch (category) {
      case positive:
        return Colors.green; // positivo = verde
      case negative:
        return Colors.red; // negativo = vermelho
      case social:
        return Colors.amber; // social = amarelo
      default:
        return Colors.grey; // fallback
    }
  }
}
