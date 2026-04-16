// lib/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:wellness_tracker/screens/login_screen.dart';
import 'package:wellness_tracker/screens/signup_screen.dart';
import 'package:wellness_tracker/screens/dashboard_screen.dart';
import 'package:wellness_tracker/screens/profile_screen.dart';
import 'package:wellness_tracker/screens/workout_placeholder.dart';
import 'package:wellness_tracker/screens/progress_placeholder.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: 'signup',
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        name: 'dashboard',
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        name: 'profile',
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        name: 'workouts',
        path: '/workouts',
        builder: (context, state) => const WorkoutPlaceholderScreen(),
      ),
      GoRoute(
        name: 'progress',
        path: '/progress',
        builder: (context, state) => const ProgressPlaceholderScreen(),
      ),
    ],
  );
}