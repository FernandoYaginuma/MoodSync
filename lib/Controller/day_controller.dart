import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/Model/day_model.dart';

class DayController extends ChangeNotifier {
  final DayModel day;
  bool isLoading = false;

  DayController({required this.day});

  void setEmotion(String emotion) {
    day.emotion = emotion;
    notifyListeners();
  }

  Future<void> salvar(String note) async {
    isLoading = true;
    notifyListeners();

    day.note = note;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final docId = day.formattedDate;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('moodEntries')
        .doc(docId);

    await docRef.set(day.toJson(), SetOptions(merge: true));

    isLoading = false;
    notifyListeners();
  }
}