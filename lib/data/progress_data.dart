class ProgressData {
  String id;
  DateTime date;
  int duration;
  int calories;
  int xp; // ✅ ADD THIS

  ProgressData({
    required this.id,
    required this.date,
    required this.duration,
    required this.calories,
    required this.xp,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'duration': duration,
      'calories': calories,
      'xp': xp,
    };
  }

  factory ProgressData.fromMap(String id, Map data) {
    return ProgressData(
      id: id,
      date: DateTime.parse(data['date']),
      duration: data['duration'],
      calories: data['calories'],
      xp: data['xp'] ?? 0,
    );
  }
}
