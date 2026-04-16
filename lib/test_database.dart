// lib/test_database.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TestDatabaseScreen extends StatelessWidget {
  const TestDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final database = FirebaseDatabase.instance.ref();
                await database.child('test').set({
                  'message': 'Hello from Flutter!',
                  'timestamp': DateTime.now().toIso8601String(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data saved! Check Firebase Console')),
                );
              },
              child: const Text('Save Test Data'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final database = FirebaseDatabase.instance.ref();
                DatabaseEvent event = await database.child('test').once();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data: ${event.snapshot.value}')),
                );
              },
              child: const Text('Read Test Data'),
            ),
          ],
        ),
      ),
    );
  }
}