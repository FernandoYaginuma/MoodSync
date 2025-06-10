import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android2/Model/professional_model.dart';

enum ProfessionalSortOrder { none, az, za }

class ProfessionalController {
  final List<ProfessionalModel> _allProfessionals = [];
  String _lastQuery = "";

  final ValueNotifier<List<ProfessionalModel>> availableProfessionals =
      ValueNotifier([]);
  final ValueNotifier<List<ProfessionalModel>> addedProfessionals =
      ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<ProfessionalSortOrder> sortOrder =
      ValueNotifier(ProfessionalSortOrder.none);

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final professionalsSnapshot =
          await FirebaseFirestore.instance.collection('profissional').get();
      _allProfessionals.clear();
      _allProfessionals.addAll(professionalsSnapshot.docs
          .map((doc) => ProfessionalModel.fromJson(doc.id, doc.data())));

      search("");

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final List<String> addedIds =
          List<String>.from(userDoc.data()?['professionalIds'] ?? []);

      addedProfessionals.value = _allProfessionals
          .where((p) => addedIds.contains(p.id))
          .toList();
    } catch (e) {
      debugPrint("Erro ao buscar dados dos profissionais: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setSortOrder(ProfessionalSortOrder newOrder) {
    sortOrder.value = newOrder;
    search(_lastQuery);
  }

  void search(String query) {
    _lastQuery = query;
    List<ProfessionalModel> filteredList;

    if (query.isEmpty) {
      filteredList = List.from(_allProfessionals);
    } else {
      final lowerCaseQuery = query.toLowerCase();
      filteredList = _allProfessionals
          .where((p) => p.name.toLowerCase().contains(lowerCaseQuery))
          .toList();
    }

    switch (sortOrder.value) {
      case ProfessionalSortOrder.az:
        filteredList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ProfessionalSortOrder.za:
        filteredList.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ProfessionalSortOrder.none:
      default:
        break;
    }

    availableProfessionals.value = filteredList;
  }

  void addProfessional(ProfessionalModel professional) {
    final currentList = addedProfessionals.value;
    if (!currentList.any((p) => p.id == professional.id)) {
      addedProfessionals.value = [...currentList, professional];
    }
  }

  void removeProfessional(ProfessionalModel professional) {
    addedProfessionals.value =
        addedProfessionals.value.where((p) => p.id != professional.id).toList();
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
      debugPrint("Erro ao salvar profissionais: $e");
      return false;
    }
  }

  void dispose() {
    availableProfessionals.dispose();
    addedProfessionals.dispose();
    isLoading.dispose();
    sortOrder.dispose();
  }
}