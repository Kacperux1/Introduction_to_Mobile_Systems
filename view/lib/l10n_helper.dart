import 'package:flutter/material.dart';

class S {
  final Locale locale;
  S(this.locale);

  static S of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return S(locale);
  }

  static const _translations = {
    'en': {
      'app_title': 'BookTrade',
      'login': 'Log in',
      'register': 'Register',
      'username': 'Username',
      'password': 'Password',
      'email': 'Email',
      'number': 'Phone Number',
      'country': 'Country',
      'city': 'City',
      'no_account': 'Don\'t have an account? Register',
      'buy_books': 'Buy books for your studies',
      'sell_books': 'Sell books you no longer use',
      'reviews': 'give reviews of books',
      'ai_recommendations': 'AI Book Recommendations',
      'logout': 'Log out',
      'your_account': 'Your Account',
      'faq': 'FAQ',
      'audio_settings': 'Audio settings',
      'language': 'Language',
      'preferences': 'Preferences',
      'search_hint': 'What are you looking for?',
      'list_for_sale': 'List for Sale',
      'save_changes': 'Save Changes',
      'voice_input': 'Voice input',
      'loading': 'Loading',
      'book_details': 'Book Details',
      'title': 'Title',
      'author': 'Author',
      'condition': 'Condition',
      'price': 'Price',
      'buy_now': 'Buy Now',
      'add_review': 'Add Your Review',
      'contact': 'Contact',
      'sold_by': 'Sold by',
      'book_semantics': 'Book: {title} by {author}, condition: {condition}, price: {price} zloty.',
      'view_details': 'View book details',
    },
    'pl': {
      'app_title': 'BookTrade',
      'login': 'Zaloguj się',
      'register': 'Zarejestruj się',
      'username': 'Nazwa użytkownika',
      'password': 'Hasło',
      'email': 'Email',
      'number': 'Numer telefonu',
      'country': 'Kraj',
      'city': 'Miasto',
      'no_account': 'Nie masz konta? Zarejestruj się',
      'buy_books': 'Kup książki na studia',
      'sell_books': 'Sprzedaj nieużywane książki',
      'reviews': 'dodaj recenzje książek',
      'ai_recommendations': 'Rekomendacje AI',
      'logout': 'Wyloguj się',
      'your_account': 'Twoje konto',
      'faq': 'Częste pytania',
      'audio_settings': 'Ustawienia dźwięku',
      'language': 'Język',
      'preferences': 'Preferencje',
      'search_hint': 'Czego szukasz?',
      'list_for_sale': 'Wystaw na sprzedaż',
      'save_changes': 'Zapisz zmiany',
      'voice_input': 'Wprowadzanie głosowe',
      'loading': 'Ładowanie',
      'book_details': 'Szczegóły książki',
      'title': 'Tytuł',
      'author': 'Autor',
      'condition': 'Stan',
      'price': 'Cena',
      'buy_now': 'Kup teraz',
      'add_review': 'Dodaj recenzję',
      'contact': 'Kontakt',
      'sold_by': 'Sprzedawca',
      'book_semantics': 'Książka: {title} autorstwa {author}, stan: {condition}, cena: {price} złotych.',
      'view_details': 'Zobacz szczegóły książki',
    }
  };

  String get(String key, {Map<String, String>? args}) {
    String text = _translations[locale.languageCode]?[key] ?? _translations['en']![key]!;
    if (args != null) {
      args.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }
}
