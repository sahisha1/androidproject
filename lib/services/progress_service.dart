import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/progress_data.dart';

class ProgressService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref("progress");

  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  // ✅ Add progress (user-specific)
  Future<void> addProgress(ProgressData progress) async {
    final userRef = _db.child(_uid);
    final newRef = userRef.push();

    await newRef.set(progress.toMap());
  }

  // ✅ Get progress (user-specific)
  Stream<List<ProgressData>> getProgress() {
    final userRef = _db.child(_uid);

    return userRef.onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      return data.entries.map((entry) {
        return ProgressData.fromMap(entry.key, entry.value);
      }).toList();
    });
  }
}
