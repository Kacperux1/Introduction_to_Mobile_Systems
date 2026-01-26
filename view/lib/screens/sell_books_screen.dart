import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        _showSnackBar('You must be logged in to sell a book.', isError: true);
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
        _showSnackBar('Book listed for sale!');
        Navigator.pop(context);
      } else {
        _showSnackBar('Failed to list book. Error: ${response.body}', isError: true);
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Sell a Book', style: TextStyle(color: theme.appBarTheme.foregroundColor)),
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
              _buildTextField(_titleController, 'Title', theme),
              const SizedBox(height: 16.0),
              _buildTextField(_authorController, 'Author', theme),
              const SizedBox(height: 16.0),
              _buildTextField(_priceController, 'Price', theme, keyboardType: TextInputType.number),
              const SizedBox(height: 16.0),
              _buildConditionDropdown(theme),
              const SizedBox(height: 32.0),
              Semantics(
                button: true,
                label: 'List book for sale',
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
                  child: const Text('List for Sale', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            return 'Please enter a $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildConditionDropdown(ThemeData theme) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    
    return Semantics(
      label: 'Select book condition',
      child: DropdownButtonFormField<String>(
        value: _selectedCondition,
        dropdownColor: isHighContrast ? Colors.black : Colors.white,
        style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black),
        items: ['Like New', 'Very Good', 'Good', 'Acceptable', 'Visibly Used']
            .map((condition) => DropdownMenuItem(
                  value: condition, 
                  child: Text(condition, style: TextStyle(color: isHighContrast ? Colors.yellow : Colors.black))
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCondition = value!;
          });
        },
        decoration: InputDecoration(
          labelText: 'Condition',
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
