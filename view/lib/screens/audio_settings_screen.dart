import 'package:flutter/material.dart';
import '../main.dart';

class AudioSettingsScreen extends StatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  double _volume = 0.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSettings = ThemeSettings.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    if (themeSettings == null) return const Scaffold(body: Center(child: Text('Settings not found')));

    Color getTextColor() {
      if (isHighContrast) return Colors.yellow;
      if (isDarkMode || isDefaultMode) return Colors.white;
      return Colors.black;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Audio Settings', style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Output Settings', getTextColor()),
          Semantics(
            label: 'Volume control slider',
            value: '${(_volume * 100).toInt()}%',
            child: ListTile(
              title: Text('Volume', style: TextStyle(color: getTextColor())),
              subtitle: Slider(
                value: _volume,
                onChanged: (val) => setState(() => _volume = val),
                activeColor: isHighContrast ? Colors.yellow : theme.primaryColor,
                inactiveColor: isHighContrast ? Colors.yellow.withOpacity(0.3) : Colors.grey,
              ),
              leading: Icon(Icons.volume_up, color: getTextColor()),
            ),
          ),
          const Divider(),
          _buildSectionHeader('Accessibility Audio', getTextColor()),
          Semantics(
            label: 'Voice feedback toggle',
            hint: 'Enable or disable spoken feedback for interactions',
            child: SwitchListTile(
              title: Text('Voice Feedback', style: TextStyle(color: getTextColor())),
              subtitle: Text('Enable spoken feedback for UI elements', style: TextStyle(color: getTextColor().withOpacity(0.7))),
              value: themeSettings.isVoiceFeedbackEnabled,
              onChanged: (val) => themeSettings.updateVoiceFeedback(val),
              secondary: Icon(Icons.record_voice_over, color: getTextColor()),
              activeColor: isHighContrast ? Colors.yellow : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
