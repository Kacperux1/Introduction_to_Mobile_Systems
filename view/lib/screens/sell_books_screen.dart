import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n_helper.dart';

class SellBooksScreen extends StatefulWidget {
  const SellBooksScreen({super.key});

  @override
  State<SellBooksScreen> createState() => _SellBooksScreenState();
}

class _SellBooksScreenState extends State<SellBooksScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCondition = 'Like New';

  Future<void> _submitForm() async {
    final s = S.of(context);
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        _showSnackBar(s.get('login_required_sell'), isError: true);
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/books'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'author': _authorController.text,
          'condition': _selectedCondition,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'imageUrl': 'https://images.pexels.com/photos/1290141/pexels-photo-1290141.jpeg',
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar(s.get('book_listed'));
        Navigator.pop(context);
      } else {
        _showSnackBar(s.get('list_failed', args: {'error': response.body}), isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final s = S.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('sell_book_title'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: isHighContrast ? Colors.black : (isDefaultMode ? Colors.green : theme.appBarTheme.backgroundColor),
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_titleController, s.get('title'), theme),
              const SizedBox(height: 16.0),
              _buildTextField(_authorController, s.get('author'), theme),
              const SizedBox(height: 16.0),
              _buildTextField(_priceController, s.get('price'), theme, keyboardType: TextInputType.number),
              const SizedBox(height: 16.0),
              _buildConditionDropdown(theme, s),
              const SizedBox(height: 32.0),
              Semantics(
                button: true,
                label: s.get('list_for_sale'),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighContrast ? Colors.black : (isDefaultMode ? Colors.green : theme.colorScheme.secondaryContainer),
                    foregroundColor: isHighContrast ? Colors.yellow : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
                    ),
                  ),
                  child: Text(s.get('list_for_sale'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, ThemeData theme, {TextInputType keyboardType = TextInputType.text}) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final s = S.of(context);
    
    return Semantics(
      label: 'Input field for $label',
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isHighContrast ? Colors.yellow : Colors.grey[700]),
          filled: true,
          fillColor: isHighContrast ? Colors.black : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return s.get('enter_field_error', args: {'field': label});
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConditionDropdown(ThemeData theme, S s) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    
    return Semantics(
      label: 'Select book condition',
      child: DropdownButtonFormField<String>(
        value: _selectedCondition,
        dropdownColor: isHighContrast ? Colors.black : Colors.white,
        style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black),
        items: [
          {'key': 'Like New', 'value': s.get('condition_like_new')},
          {'key': 'Very Good', 'value': s.get('condition_very_good')},
          {'key': 'Good', 'value': s.get('condition_good')},
          {'key': 'Acceptable', 'value': s.get('condition_acceptable')},
          {'key': 'Visibly Used', 'value': s.get('condition_used')},
        ].map((item) => DropdownMenuItem(
                  value: item['key'], 
                  child: Text(item['value']!, style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black))
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCondition = value!;
          });
        },
        decoration: InputDecoration(
          labelText: s.get('condition'),
          labelStyle: TextStyle(color: isHighContrast ? Colors.yellow : Colors.grey[700]),
          filled: true,
          fillColor: isHighContrast ? Colors.black : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
