import 'package:flutter/material.dart';
import '../main.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeSettings = ThemeSettings.of(context);

    if (themeSettings == null) return const Scaffold(body: Center(child: Text('Settings not found')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Accessibility & Theme',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // High Contrast Switch
          SwitchListTile(
            title: const Text('High Contrast Mode'),
            subtitle: const Text('Enhances visibility with higher contrast colors'),
            value: themeSettings.isHighContrast,
            onChanged: (bool value) {
              themeSettings.updateHighContrast(value);
            },
            secondary: const Icon(Icons.contrast),
          ),
          
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Theme Mode', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),

          // Theme Mode Radio Buttons
          RadioListTile<ThemeMode>(
            title: const Text('Default'),
            value: ThemeMode.system,
            groupValue: themeSettings.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) themeSettings.updateThemeMode(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            groupValue: themeSettings.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) themeSettings.updateThemeMode(value);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            value: ThemeMode.dark,
            groupValue: themeSettings.themeMode,
            onChanged: (ThemeMode? value) {
              if (value != null) themeSettings.updateThemeMode(value);
            },
          ),
        ],
      ),
    );
  }
}
