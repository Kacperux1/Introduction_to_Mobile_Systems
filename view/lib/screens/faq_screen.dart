import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);

    final List<Map<String, String>> faqs = [
      {
        'question': 'How do I buy a book?',
        'answer': 'Navigate to the "Buy books" screen from the home page, browse the available titles, and click on the "Buy" button for the book you want.'
      },
      {
        'question': 'Can I sell my old textbooks?',
        'answer': 'Yes! Go to the "Sell books" screen, fill in the details about your book, and it will be listed for other students to buy.'
      },
      {
        'question': 'How do I change my preferences?',
        'answer': 'Open the right menu on the home screen and select "Preferences" to change the theme, contrast, and other settings.'
      },
      {
        'question': 'Is my data secure?',
        'answer': 'We take security seriously. Your data is encrypted and handled according to modern safety standards.'
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
        title: Text('FAQ', style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Semantics(
            container: true,
            label: 'FAQ item: ${faq['question']}',
            child: Card(
              color: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white.withOpacity(0.1) : theme.cardColor),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
              ),
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
          );
        },
      ),
    );
  }
}
