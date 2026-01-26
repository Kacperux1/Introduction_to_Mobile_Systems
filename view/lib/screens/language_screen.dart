import 'package:flutter/material.dart';
import '../main.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeSettings = ThemeSettings.of(context);
    
    if (themeSettings == null) return const Scaffold(body: Center(child: Text('Settings not found')));

    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    final List<Map<String, dynamic>> languages = [
      {'name': 'Polski', 'locale': const Locale('pl', 'PL')},
      {'name': 'English', 'locale': const Locale('en', 'US')},
    ];

    Color getTextColor() {
      if (isHighContrast) return Colors.yellow;
      if (isDarkMode || isDefaultMode) return Colors.white;
      return Colors.black;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(themeSettings.locale.languageCode == 'pl' ? 'Język' : 'Language', 
          style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final bool isSelected = themeSettings.locale.languageCode == lang['locale'].languageCode;

          return Semantics(
            button: true,
            selected: isSelected,
            label: '${lang['name']}, ${isSelected ? (lang['locale'].languageCode == 'pl' ? 'wybrany' : 'selected') : ''}',
            child: Card(
              color: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white.withOpacity(0.1) : theme.cardColor),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(
                  color: isSelected ? (isHighContrast ? Colors.yellow : Colors.white) : (isHighContrast ? Colors.yellow.withOpacity(0.3) : Colors.transparent),
                  width: isSelected ? 3 : 1
                ),
              ),
              child: ListTile(
                title: Text(
                  lang['name']!,
                  style: TextStyle(
                    color: getTextColor(), 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check_circle, color: getTextColor()) : null,
                onTap: () {
                  themeSettings.updateLocale(lang['locale']);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
