import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:view/models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final String token;
  final UserProfile initialProfile;

  const EditProfileScreen({
    super.key,
    required this.token,
    required this.initialProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _emailController;
  late TextEditingController _numberController;
  late TextEditingController _countryController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialProfile.email);
    _numberController = TextEditingController(text: widget.initialProfile.number);
    _countryController = TextEditingController(text: widget.initialProfile.country);
    _cityController = TextEditingController(text: widget.initialProfile.city);
  }

  Future<void> _updateProfile() async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/api/me'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'email': _emailController.text,
          'number': _numberController.text,
          'country': _countryController.text,
          'city': _cityController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showErrorSnackBar('Update failed: ${response.body}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    }
  }

    void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_emailController, 'Email'),
            _buildTextField(_numberController, 'Number'),
            _buildTextField(_countryController, 'Country'),
            _buildTextField(_cityController, 'City'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _numberController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
