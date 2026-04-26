// lib/services/auth_service.dart (DEBUG VERSION)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserModel?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required int age,
    required double weight,
    required String goal,
  }) async {
    try {
      print('===== SIGN UP STARTED =====');
      print('Email: $email');
      print('Name: $name');

      // Step 1: Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Step 1: User created in Auth');
      print('UID: ${userCredential.user!.uid}');

      // Step 2: Prepare user data
      final userData = {
        'name': name,
        'email': email,
        'age': age,
        'weight': weight,
        'goal': goal,
        'createdAt': DateTime.now().toIso8601String(),
        'totalXP': 0,
      };

      print('✅ Step 2: User data prepared');
      print('Data: $userData');

      // Step 3: Save to Realtime Database
      print('✅ Step 3: Attempting to save to database...');
      await _database.child('users/${userCredential.user!.uid}').set(userData);
      print('✅ Step 3: Data saved to Realtime Database!');

      // Step 4: Verify it was saved
      DatabaseEvent event = await _database.child('users/${userCredential.user!.uid}').once();
      print('✅ Step 4: Verification - Data exists: ${event.snapshot.value != null}');

      print('===== SIGN UP COMPLETED SUCCESSFULLY =====');

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        age: age,
        weight: weight,
        goal: goal,
        createdAt: DateTime.now(),
      );

      return newUser;
    } catch (e) {
      print('===== SIGN UP FAILED =====');
      print('❌ Error: $e');
      print('❌ Error type: ${e.runtimeType}');
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ User signed in: ${userCredential.user!.uid}');
      return userCredential.user;
    } catch (e) {
      print('❌ SignIn Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    print('✅ User signed out');
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      print('🔍 Fetching user data for: $uid');
      DatabaseEvent event = await _database.child('users/$uid').once();
      DataSnapshot snapshot = event.snapshot;

      print('📦 Snapshot value: ${snapshot.value}');

      if (snapshot.value != null) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
        print('✅ User data found: ${userData['name']}');
        return UserModel(
          uid: uid,
          name: userData['name'] ?? '',
          email: userData['email'] ?? '',
          age: userData['age'] ?? 0,
          weight: (userData['weight'] ?? 0).toDouble(),
          goal: userData['goal'] ?? 'fitness',
          createdAt: userData['createdAt'] != null
              ? DateTime.parse(userData['createdAt'])
              : DateTime.now(),
        );
      } else {
        print('⚠️ No user data found for: $uid');
        return null;
      }
    } catch (e) {
      print('❌ GetUserData Error: $e');
      return null;
    }
  }

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
      updateData['lastUpdated'] = DateTime.now().toIso8601String();

      await _database.child('users/$uid').update(updateData);
      print('✅ User profile updated');
      return true;
    } catch (e) {
      print('❌ UpdateProfile Error: $e');
      return false;
    }
  }
}
