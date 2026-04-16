// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  UserModel? _userData;
  bool _isLoading = true;
  bool _isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _selectedGoal = 'fitness';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.getCurrentUser();
    if (user != null) {
      final userData = await _auth.getUserData(user.uid);
      setState(() {
        _userData = userData;
        if (userData != null) {
          _nameController.text = userData.name;
          _ageController.text = userData.age.toString();
          _weightController.text = userData.weight.toString();
          _selectedGoal = userData.goal;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final user = _auth.getCurrentUser();
      if (user != null) {
        final success = await _auth.updateUserProfile(
          uid: user.uid,
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text.trim()),
          weight: double.parse(_weightController.text.trim()),
          goal: _selectedGoal,
        );

        if (success && mounted) {
          Fluttertoast.showToast(msg: 'Profile updated successfully!');
          setState(() {
            _isEditing = false;
            _isLoading = false;
          });
          await _loadUserData();
        } else {
          Fluttertoast.showToast(msg: 'Update failed. Try again.');
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.orange.shade700,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.orange.shade100,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow('Email', _userData?.email ?? ''),
                      const Divider(),
                      _buildEditableField('Full Name', _nameController, _isEditing),
                      const Divider(),
                      _buildEditableField('Age', _ageController, _isEditing, isNumber: true),
                      const Divider(),
                      _buildEditableField('Weight (kg)', _weightController, _isEditing, isNumber: true),
                      const Divider(),
                      _buildDropdownField(),
                    ],
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _loadUserData();
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, bool isEditing, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (isEditing)
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: isNumber ? TextInputType.number : TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  isDense: true,
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            )
          else
            Text(controller.text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    final Map<String, String> goals = {
      'weight_loss': 'Weight Loss',
      'muscle_gain': 'Muscle Gain',
      'fitness': 'Fitness',
      'endurance': 'Endurance',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Fitness Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (_isEditing)
            DropdownButton<String>(
              value: _selectedGoal,
              items: goals.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedGoal = value!),
            )
          else
            Text(goals[_selectedGoal] ?? _selectedGoal, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}