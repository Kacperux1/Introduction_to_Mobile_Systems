import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../l10n_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();

  final String _baseUrl = 'http://10.0.2.2:8080';

  Future<void> _register() async {
    final s = S.of(context);
    if (_loginController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _emailController.text.isEmpty) {
      _showErrorSnackBar(s.get('required_fields_error'));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'login': _loginController.text,
          'password': _passwordController.text,
          'email': _emailController.text,
          'number': _numberController.text,
          'country': _countryController.text,
          'city': _cityController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(s.get('registration_success')),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        _showErrorSnackBar(s.get('registration_failed', args: {'error': response.body}));
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
        title: Text(
          s.get('register_title'),
          style: TextStyle(color: theme.appBarTheme.foregroundColor),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_loginController, '${s.get('username')}*', theme),
              _buildTextField(_passwordController, '${s.get('password')}*', theme, obscureText: true),
              _buildTextField(_emailController, '${s.get('email')}*', theme),
              _buildTextField(_numberController, s.get('number'), theme),
              _buildTextField(_countryController, s.get('country'), theme),
              _buildTextField(_cityController, s.get('city'), theme),
              const SizedBox(height: 40),
              Semantics(
                button: true,
                label: s.get('submit_registration'),
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDefaultMode ? Colors.grey[300] : (isHighContrast ? Colors.black : theme.colorScheme.secondaryContainer),
                    foregroundColor: isHighContrast ? Colors.yellow : (isDefaultMode ? Colors.black : theme.colorScheme.onSecondaryContainer),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    s.get('register'),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, ThemeData theme, {bool obscureText = false}) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    
    Color labelColor;
    if (isHighContrast) {
      labelColor = Colors.yellow;
    } else if (isDarkMode || theme.scaffoldBackgroundColor == const Color(0xFF00008B)) {
      labelColor = Colors.white;
    } else {
      labelColor = Colors.black;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: 'Label for $label',
            child: Text(label, style: TextStyle(color: labelColor, fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: isHighContrast ? Colors.yellow : theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
