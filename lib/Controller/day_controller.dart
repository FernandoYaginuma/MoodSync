import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/Model/day_model.dart';

class DayController extends ChangeNotifier {
  final DayModel day;

  /// ✅ novo: se true, não deixa alterar emoções
  final bool lockEmotions;

  bool isLoading = false;

  DayController({
    required this.day,
    this.lockEmotions = false,
  });

  void setEmotions(List<String> emotions) {
    if (lockEmotions) return; // ✅ trava
    if (emotions.length > 3) {
      day.emotions = emotions.take(3).toList();
    } else {
      day.emotions = emotions;
    }
    notifyListeners();
  }

  void toggleEmotion(String feeling) {
    if (lockEmotions) return; // ✅ trava
    if (day.emotions.contains(feeling)) {
      day.emotions.remove(feeling);
    } else {
      if (day.emotions.length >= 3) return;
      day.emotions.add(feeling);
    }
    notifyListeners();
  }

  void toggleActivity(String activityId) {
    if (day.activityIds.contains(activityId)) {
      day.activityIds.remove(activityId);
    } else {
      day.activityIds.add(activityId);
    }
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

    final dataToSave = day.toJson();
    dataToSave['lastUpdatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(dataToSave, SetOptions(merge: true));

    isLoading = false;
    notifyListeners();
  }
}
