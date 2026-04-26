// lib/screens/workout_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../data/workout_data.dart';
import '../models/workout_model.dart';
class WorkoutDetailScreen extends StatefulWidget {
  final String workoutId;
  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late WorkoutModel _workout;

  int _currentExerciseIndex = 0;
  int _timeRemaining = 0;
  bool _isTimerRunning = false;
  List<bool> _completedExercises = [];

  @override
  void initState() {
    super.initState();
    _workout = WorkoutData.getWorkouts().firstWhere(
          (w) => w.id == widget.workoutId,
    );
    _completedExercises = List.filled(_workout.exercises.length, false);
  }

  void _startTimer(int seconds) {
    setState(() {
      _timeRemaining = seconds;
      _isTimerRunning = true;
    });
    _runTimer();
  }

  void _runTimer() async {
    while (_isTimerRunning && _timeRemaining > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isTimerRunning) break;
      setState(() {
        if (_timeRemaining > 0) _timeRemaining--;
      });
      if (_timeRemaining == 0) {
        setState(() => _isTimerRunning = false);
        _markExerciseComplete();
        break;
      }
    }
  }

  void _markExerciseComplete() {
    setState(() {
      _completedExercises[_currentExerciseIndex] = true;
    });

    if (_currentExerciseIndex + 1 < _workout.exercises.length) {
      _showNextExerciseDialog();
    } else {
      _completeWorkout();
    }
  }

  void _showNextExerciseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Great Job! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Exercise ${_currentExerciseIndex + 1} completed!'),
            const SizedBox(height: 10),
            Text('Next: ${_workout.exercises[_currentExerciseIndex + 1].name}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _currentExerciseIndex++);
              _showExerciseDialog();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showExerciseDialog() {
    final exercise = _workout.exercises[_currentExerciseIndex];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie Animation
              Container(
                height: 250,
                width: double.infinity,
                child: Lottie.asset(
                  exercise.animationPath,
                  repeat: true,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 50, color: Colors.orange),
                            SizedBox(height: 10),
                            Text('Animation not found'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                exercise.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (exercise.reps > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${exercise.reps} REPETITIONS',
                    style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.bold),
                  ),
                ),
              if (exercise.duration > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${exercise.duration} SECONDS',
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 15),
              Text(
                exercise.instructions,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (exercise.duration > 0) {
                    _startTimer(exercise.duration);
                  } else {
                    _startTimer(30);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'START EXERCISE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeWorkout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.orange),
            const SizedBox(height: 10),
            const Text(
              'Workout Complete!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('You earned ${_workout.xpReward} XP!'),
            if (_workout.badgeReward.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('🏅 New Badge: ${_workout.badgeReward}'),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.go('/dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
            ),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress
    int completedCount = _completedExercises.where((c) => c == true).length;
    double progress = _workout.exercises.isNotEmpty
        ? completedCount / _workout.exercises.length
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_workout.title),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white30,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Display
            if (_isTimerRunning)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'CURRENT EXERCISE',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _workout.exercises[_currentExerciseIndex].name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: _timeRemaining /
                                (_workout.exercises[_currentExerciseIndex].duration > 0
                                    ? _workout.exercises[_currentExerciseIndex].duration.toDouble()
                                    : 30),
                            strokeWidth: 10,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$_timeRemaining',
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'seconds',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Exercises List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 EXERCISES',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._workout.exercises.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Exercise exercise = entry.value;
                    bool isCompleted = _completedExercises[idx];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: isCompleted ? Colors.green : Colors.orange.shade100,
                          child: Icon(
                            isCompleted ? Icons.check : Icons.fitness_center,
                            size: 25,
                            color: isCompleted ? Colors.white : Colors.orange.shade700,
                          ),
                        ),
                        title: Text(
                          exercise.name,
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          exercise.reps > 0
                              ? '${exercise.reps} reps'
                              : '${exercise.duration} seconds',
                        ),
                        trailing: isCompleted
                            ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                            : IconButton(
                          icon: const Icon(Icons.play_circle, color: Colors.orange, size: 32),
                          onPressed: () => _showExerciseDialog(),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 25),

                  // Start Workout Button (if not started)
                  if (!_isTimerRunning && !_completedExercises.every((c) => c))
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showExerciseDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'START WORKOUT',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Completion Message
                  if (_completedExercises.every((c) => c))
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.celebration, color: Colors.green, size: 30),
                          SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Workout Complete! Great job! 🎉',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
