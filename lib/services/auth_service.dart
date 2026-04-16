// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign Up with Email
  Future<UserModel?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weight,
    required String goal,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user data for Realtime Database
      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        age: age,
        weight: weight,
        goal: goal,
        createdAt: DateTime.now(),
      );

      // Save to Realtime Database
      await _database.child('users/${userCredential.user!.uid}').set({
        'name': name,
        'email': email,
        'age': age,
        'weight': weight,
        'goal': goal,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return newUser;
    } catch (e) {
      print('SignUp Error: $e');
      return null;
    }
  }

  // Sign In with Email
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('SignIn Error: $e');
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Data from Realtime Database
  Future<UserModel?> getUserData(String uid) async {
    try {
      DatabaseEvent event = await _database.child('users/$uid').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel(
          uid: uid,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          age: userData['age'] ?? 0,
          weight: (userData['weight'] ?? 0).toDouble(),
          goal: userData['goal'] ?? 'fitness',
          createdAt: DateTime.parse(userData['createdAt'] ?? DateTime.now().toIso8601String()),
        );
      }
      return null;
    } catch (e) {
      print('GetUserData Error: $e');
      return null;
    }
  }

  // Update User Profile
  Future<bool> updateUserProfile({
    required String uid,
    String? name,
    int? age,
    double? weight,
    String? goal,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (weight != null) updateData['weight'] = weight;
      if (goal != null) updateData['goal'] = goal;

      await _database.child('users/$uid').update(updateData);
      return true;
    } catch (e) {
      print('UpdateProfile Error: $e');
      return false;
    }
  }
}