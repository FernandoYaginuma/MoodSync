class ProfessionalModel {
  final List<String> availableProfessionals = ['Fulano', 'Ciclano'];
  final List<String> addedProfessionals = [];

  static final List<String> savedProfessionals = [];

  void loadSavedProfessionals() {
    addedProfessionals.clear();
    addedProfessionals.addAll(savedProfessionals);
  }

  void saveProfessionals() {
    savedProfessionals
      ..clear()
      ..addAll(addedProfessionals);
  }
}
