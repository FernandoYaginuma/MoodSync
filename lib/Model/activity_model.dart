class ActivityModel {
  final String id;
  final String name;
  final String iconName;

  ActivityModel({
    required this.id,
    required this.name,
    required this.iconName,
  });

  factory ActivityModel.fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return ActivityModel(
      id: documentId,
      name: data['name'] ?? '',
      iconName: data['icon'] ?? 'circle',
    );
  }
}