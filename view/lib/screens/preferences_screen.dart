import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n_helper.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeSettings = ThemeSettings.of(context);
    final s = S.of(context);

    if (themeSettings == null) return Scaffold(body: Center(child: Text(s.get('settings_not_found'))));

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('preferences')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            s.get('accessibility_theme_title'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // High Contrast Switch
          Semantics(
            container: true,
            label: s.get('high_contrast_mode'),
            hint: s.get('tap_to_select'),
            child: SwitchListTile(
              title: Text(s.get('high_contrast_mode')),
              subtitle: Text(s.get('high_contrast_subtitle')),
              value: themeSettings.isHighContrast,
              onChanged: (bool value) {
                themeSettings.updateHighContrast(value);
              },
              secondary: const Icon(Icons.contrast),
            ),
          ),
          
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(s.get('theme_mode'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),

          // Theme Mode Radio Buttons
          _buildRadioTile(
            title: s.get('theme_default'),
            value: ThemeMode.system,
            groupValue: themeSettings.themeMode,
            onChanged: themeSettings.updateThemeMode,
            s: s,
          ),
          _buildRadioTile(
            title: s.get('theme_light'),
            value: ThemeMode.light,
            groupValue: themeSettings.themeMode,
            onChanged: themeSettings.updateThemeMode,
            s: s,
          ),
          _buildRadioTile(
            title: s.get('theme_dark'),
            value: ThemeMode.dark,
            groupValue: themeSettings.themeMode,
            onChanged: themeSettings.updateThemeMode,
            s: s,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile({
    required String title,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode> onChanged,
    required S s,
  }) {
    final bool isSelected = value == groupValue;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$title, ${isSelected ? s.get('selected') : ''}',
      onTapHint: s.get('tap_to_select'),
      child: RadioListTile<ThemeMode>(
        title: Text(title),
        value: value,
        groupValue: groupValue,
        onChanged: (ThemeMode? val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }
}
