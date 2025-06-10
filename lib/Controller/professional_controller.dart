import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/Model/professional_model.dart';

class ProfessionalController {
  final ValueNotifier<List<ProfessionalModel>> availableProfessionals =
      ValueNotifier([]);
  final ValueNotifier<List<ProfessionalModel>> addedProfessionals =
      ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> fetchData() async {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    final professionalsSnapshot =
        await FirebaseFirestore.instance.collection('professionals').get();
    final allProfessionals = professionalsSnapshot.docs
        .map((doc) => ProfessionalModel.fromJson(doc.id, doc.data()))
        .toList();

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final List<String> addedIds =
        List<String>.from(userDoc.data()?['professionalIds'] ?? []);

    availableProfessionals.value = allProfessionals;
    addedProfessionals.value = allProfessionals
        .where((p) => addedIds.contains(p.id))
        .toList();
    isLoading.value = false;
  }

  void addProfessional(ProfessionalModel professional) {
    final currentList = addedProfessionals.value;
    if (!currentList.any((p) => p.id == professional.id)) {
      addedProfessionals.value = [...currentList, professional];
    }
  }

  void removeProfessional(ProfessionalModel professional) {
    final currentList = addedProfessionals.value;
    addedProfessionals.value =
        currentList.where((p) => p.id != professional.id).toList();
  }

  Future<bool> saveProfessionals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final addedIds = addedProfessionals.value.map((p) => p.id).toList();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'professionalIds': addedIds});
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    availableProfessionals.dispose();
    addedProfessionals.dispose();
    isLoading.dispose();
  }
}