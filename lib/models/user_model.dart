// lib/models/user_model.dart
class UserModel {
  String uid;
  String name;
  String email;
  int age;
  double weight;
  String goal;
  DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.goal,
    required this.createdAt,
  });

  // Convert to Map for Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'weight': weight,
      'goal': goal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Realtime Database data
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      weight: (map['weight'] ?? 0).toDouble(),
      goal: map['goal'] ?? 'fitness',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}