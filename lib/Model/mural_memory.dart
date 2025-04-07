class MuralMemory {
  static final Map<String, MuralData> _dataByDate = {};

  static void saveMural(String dateKey, MuralData data) {
    _dataByDate[dateKey] = data;
  }

  static MuralData? getMural(String dateKey) {
    return _dataByDate[dateKey];
  }
}

class MuralData {
  final String feeling;
  final String text;

  MuralData({required this.feeling, required this.text});
}
