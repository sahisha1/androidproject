// lib/data/workout_data.dart
import '../models/workout_model.dart';

class WorkoutData {
  static List<WorkoutModel> getWorkouts() {
    return [
      WorkoutModel(
        id: 'workout_001',
        title: '🏃 Full Body Basic',
        description: 'Perfect for beginners. Start your fitness journey here!',
        level: 'basic',
        duration: 60,
        calories: 150,
        thumbnail: 'https://picsum.photos/id/100/400/200',
        xpReward: 50,
        badgeReward: 'Beginner Badge',
        exercises: [
          Exercise(
            name: 'Jumping Jacks',
            duration: 10,
            reps: 0,
            instructions:
                'Stand with feet together, jump and spread legs while clapping overhead',
            animationPath:
                'assets/animations/jumping_jacks.json', // ✅ Jumping Jacks animation
          ),
          Exercise(
            name: 'Squats',
            duration: 10,
            reps: 0,
            instructions:
                'Stand with feet shoulder-width apart, lower body as if sitting back',
            animationPath:
                'assets/animations/squats.json', // ✅ Squats animation
          ),
          Exercise(
            name: 'Military Push Ups',
            duration: 10,
            reps: 0,
            instructions:
                'Keep body straight, lower chest to ground, elbows at 45 degrees',
            animationPath:
                'assets/animations/Military_PushUps.json', // ✅ Push ups animation
          ),
          Exercise(
            name: 'Explosive Lunges',
            duration: 10,
            reps: 0,
            instructions:
                'Step forward, lower hips, jump and switch legs in mid-air',
            animationPath:
                'assets/animations/Explosive_Lunges.json', // ✅ Lunges animation
          ),
          Exercise(
            name: 'Inchworm',
            duration: 10,
            reps: 0,
            instructions:
                'Bend over, walk hands forward to plank, walk feet to hands',
            animationPath:
                'assets/animations/inchworm.json', // ✅ Inchworm animation
          ),
        ],
      ),
      WorkoutModel(
        id: 'workout_002',
        title: '⚡ HIIT Cardio Blast',
        description: 'High intensity interval training for maximum fat burning',
        level: 'intermediate',
        duration: 600,
        calories: 350,
        thumbnail: 'https://picsum.photos/id/101/400/200',
        xpReward: 100,
        badgeReward: 'Cardio Warrior',
        exercises: [
          Exercise(
            name: 'Jumping Jacks',
            duration: 45,
            reps: 0,
            instructions: 'Rapid jumping jacks for cardio',
            animationPath: 'assets/animations/jumping_jacks.json',
          ),
          Exercise(
            name: 'Squats',
            duration: 45,
            reps: 0,
            instructions: 'Quick squats for leg strength',
            animationPath: 'assets/animations/squats.json',
          ),
          Exercise(
            name: 'Explosive Lunges',
            duration: 45,
            reps: 0,
            instructions: 'Explosive lunge jumps for power',
            animationPath: 'assets/animations/Explosive_Lunges.json',
          ),
          Exercise(
            name: 'Inchworm',
            duration: 45,
            reps: 0,
            instructions: 'Full body movement for mobility',
            animationPath: 'assets/animations/inchworm.json',
          ),
        ],
      ),
      WorkoutModel(
        id: 'workout_003',
        title: '💪 Upper Body Focus',
        description: 'Build upper body strength with these exercises',
        level: 'intermediate',
        duration: 450,
        calories: 200,
        thumbnail: 'https://picsum.photos/id/102/400/200',
        xpReward: 80,
        badgeReward: 'Upper Body Warrior',
        exercises: [
          Exercise(
            name: 'Military Push Ups',
            duration: 40,
            reps: 12,
            instructions: 'Keep body straight, lower chest to ground',
            animationPath: 'assets/animations/Military_PushUps.json',
          ),
          Exercise(
            name: 'Inchworm',
            duration: 30,
            reps: 8,
            instructions:
                'Bend over, walk hands out to plank, walk feet to hands',
            animationPath: 'assets/animations/inchworm.json',
          ),
          Exercise(
            name: 'Jumping Jacks',
            duration: 30,
            reps: 0,
            instructions: 'Active recovery between strength sets',
            animationPath: 'assets/animations/jumping_jacks.json',
          ),
        ],
      ),
    ];
  }
}
