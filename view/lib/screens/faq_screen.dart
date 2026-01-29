import 'package:flutter/material.dart';
import '../l10n_helper.dart';
import '../main.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final s = S.of(context);
    final themeSettings = ThemeSettings.of(context);

    final List<Map<String, String>> faqs = [
      {
        'question': s.get('faq_q1'),
        'answer': s.get('faq_a1')
      },
      {
        'question': s.get('faq_q2'),
        'answer': s.get('faq_a2')
      },
      {
        'question': s.get('faq_q3'),
        'answer': s.get('faq_a3')
      },
      {
        'question': s.get('faq_q4'),
        'answer': s.get('faq_a4')
      },
    ];

    Color getTextColor() {
      if (isHighContrast) return Colors.yellow;
      if (isDarkMode || isDefaultMode) return Colors.white;
      return Colors.black;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('faq_title'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          final String faqDescription = '${faq['question']}. ${faq['answer']}';

          return Semantics(
            container: true,
            label: s.get('faq_item_label', args: {'question': faq['question']!}),
            child: Card(
              color: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white.withOpacity(0.1) : (isDarkMode ? Colors.white.withOpacity(0.05) : theme.cardColor)),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
              ),
              child: InkWell(
                onTap: () => themeSettings?.speak(faqDescription),
                child: ExpansionTile(
                  title: Text(
                    faq['question']!,
                    style: TextStyle(
                      color: getTextColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconColor: getTextColor(),
                  collapsedIconColor: getTextColor(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        faq['answer']!,
                        style: TextStyle(color: getTextColor()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
