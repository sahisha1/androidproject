// lib/models/workout_model.dart
class WorkoutModel {
  String id;
  String title;
  String description;
  String level;
  int duration;
  int calories;
  String thumbnail;
  List<Exercise> exercises;
  int xpReward;
  String badgeReward;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.duration,
    required this.calories,
    required this.thumbnail,
    required this.exercises,
    required this.xpReward,
    required this.badgeReward,
  });
}

class Exercise {
  String name;
  int duration;
  int reps;
  String instructions;
  String animationPath;  // Path to Lottie JSON file

  Exercise({
    required this.name,
    required this.duration,
    required this.reps,
    required this.instructions,
    required this.animationPath,
  });
}
