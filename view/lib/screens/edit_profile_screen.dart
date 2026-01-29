import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:view/models/user_profile.dart';
import '../l10n_helper.dart';

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
    final s = S.of(context);
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/me'),
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
            SnackBar(content: Text(s.get('profile_updated')), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showErrorSnackBar(s.get('update_failed', args: {'error': response.body}));
      }
    } catch (e) {
      _showErrorSnackBar(s.get('error_occurred', args: {'error': e.toString()}));
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message), 
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('edit_profile_title'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_emailController, s.get('email'), theme),
            _buildTextField(_numberController, s.get('number'), theme),
            _buildTextField(_countryController, s.get('country'), theme),
            _buildTextField(_cityController, s.get('city'), theme),
            const SizedBox(height: 40),
            Semantics(
              button: true,
              label: s.get('save_changes'),
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isHighContrast ? Colors.black : (isDefaultMode ? Colors.grey[300] : theme.colorScheme.secondaryContainer),
                  foregroundColor: isHighContrast ? Colors.yellow : (isDefaultMode ? Colors.black : theme.colorScheme.onSecondaryContainer),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                  ),
                ),
                child: Text(
                  s.get('save_changes'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, ThemeData theme) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    Color labelColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Semantics(
            label: 'Input field for $label',
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: isHighContrast ? Colors.black : Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                ),
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
