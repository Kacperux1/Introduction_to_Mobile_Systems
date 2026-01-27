import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import 'book_details_screen.dart';
import '../l10n_helper.dart';
import '../main.dart';
import '../service/ai_chat_service.dart';

class BuyBooksScreen extends StatefulWidget {
  final bool isLoggedIn;
  const BuyBooksScreen({required this.isLoggedIn, super.key});

  @override
  State<BuyBooksScreen> createState() => _BuyBooksScreenState();
}

class _BuyBooksScreenState extends State<BuyBooksScreen> {
  late Future<List<Book>> _booksFuture;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final AiChatService _aiService = AiChatService();
  final Map<int, String> _translatedTitles = {};

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchBooks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _booksFuture = _fetchBooks(query: _searchController.text);
      });
    });
  }

  Future<List<Book>> _fetchBooks({String query = ''}) async {
    final uri = Uri.parse('http://10.0.2.2:8080/api/books').replace(queryParameters: {'title': query});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      final books = body.map((dynamic item) => Book.fromJson(item)).toList();
      _translateTitles(books);
      return books;
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<void> _translateTitles(List<Book> books) async {
    final s = S.of(context);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    
    for (var book in books) {
      _aiService.translateTitle(book.title, s.locale.languageCode, token).then((translated) {
        if (mounted && translated != book.title) {
          setState(() {
            _translatedTitles[book.id] = translated;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s.get('buy_books'), style: TextStyle(color: theme.appBarTheme.foregroundColor)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: theme.appBarTheme.foregroundColor),
      ),
      body: Column(
        children: [
          _buildSearchBar(theme, s),
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: _booksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(s.get('error_loading_books', args: {'error': snapshot.error.toString()}), style: const TextStyle(color: Colors.red)));
                } else if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Center(child: Text(s.get('no_books_found'), style: TextStyle(color: theme.textTheme.bodyLarge?.color)));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildBookCard(context, snapshot.data![index], theme, s);
                    },
                  );
                } else {
                  return Center(child: Text(s.get('no_books_found'), style: TextStyle(color: theme.textTheme.bodyLarge?.color)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, S s) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Semantics(
        label: s.get('search_hint'),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: isHighContrast ? Colors.yellow : (theme.brightness == Brightness.dark ? Colors.white : Colors.black)),
          decoration: InputDecoration(
            hintText: s.get('search_hint'),
            hintStyle: TextStyle(color: isHighContrast ? Colors.yellow.withOpacity(0.7) : Colors.grey),
            fillColor: isHighContrast ? Colors.black : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.white),
            filled: true,
            prefixIcon: Icon(Icons.search, color: isHighContrast ? Colors.yellow : Colors.grey),
            suffixIcon: Icon(Icons.filter_list, color: isHighContrast ? Colors.yellow : Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, ThemeData theme, S s) {
    final isHighContrast = theme.scaffoldBackgroundColor == const Color(0xFF301934);
    final isDarkMode = theme.scaffoldBackgroundColor == Colors.black;
    final isDefaultMode = theme.scaffoldBackgroundColor == const Color(0xFF00008B);
    final themeSettings = ThemeSettings.of(context);

    Color textColor = (isDarkMode || isDefaultMode) ? Colors.white : (isHighContrast ? Colors.yellow : Colors.black);
    final displayTitle = _translatedTitles[book.id] ?? book.title;

    final String bookDescription = s.get('book_semantics', args: {
        'title': displayTitle,
        'author': book.author,
        'condition': s.translateCondition(book.condition),
        'price': book.price.toStringAsFixed(2),
    });

    return Semantics(
      button: true,
      label: bookDescription,
      onTapHint: s.get('view_details'),
      child: InkWell(
        onTap: () {
          themeSettings?.speak(bookDescription);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(
                bookId: book.id, 
                isLoggedIn: widget.isLoggedIn,
                translatedTitle: _translatedTitles[book.id],
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: isHighContrast ? const BorderSide(color: Colors.yellow, width: 2) : BorderSide.none,
          ),
          color: isHighContrast ? Colors.black : (isDefaultMode ? Colors.white.withOpacity(0.1) : (isDarkMode ? Colors.white.withOpacity(0.05) : theme.cardColor)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: book.imageUrl,
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[400],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[400],
                      child: const Icon(Icons.book, size: 50, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s.get('title')}: $displayTitle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      const SizedBox(height: 4.0),
                      Text('${s.get('author')}: ${book.author}', style: TextStyle(fontSize: 14, color: textColor)),
                      const SizedBox(height: 8.0),
                      Text('${s.get('condition')}: ${s.translateCondition(book.condition)}', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: textColor)),
                      const SizedBox(height: 8.0),
                      Text('${s.get('price')}: ${book.price.toStringAsFixed(2)}zł',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          color: isHighContrast ? Colors.yellow : (isDarkMode ? Colors.greenAccent : Colors.green[800])
                        )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
